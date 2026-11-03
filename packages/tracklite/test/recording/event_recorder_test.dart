import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/recording/event_recorder.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';

import '../helpers/sdk.dart';

void main() {
  late TrackLiteDatabase db;
  late LogRecorder logs;

  setUp(() {
    db = TrackLiteDatabase.inMemory();
    logs = LogRecorder();
  });
  tearDown(() => db.close());

  EventRecorder recorder({int maxQueueSize = 10000}) => EventRecorder(
    database: db,
    maxQueueSize: maxQueueSize,
    logger: logs.logger(),
    newId: SequentialIds().call,
    clock: Clock.fixed(testNow),
  );

  void track(
    EventRecorder recorder,
    String name, {
    Map<String, Object> properties = const {},
    String? userId,
    DateTime? at,
  }) => recorder.record(
    name,
    properties,
    userId: userId,
    anonymousId: 'anon',
    at: at,
  );

  test(
    'an event is stored pending, stamped with its id, time and ids',
    () async {
      final events = recorder();

      track(events, ' purchase ', properties: {'price': 20}, userId: 'user_1');
      await events.idle;

      final row = (await db.eventDao.all()).single;
      expect(row.id, 'id-1');
      expect(row.name, 'purchase');
      expect(row.timestamp, testNow);
      expect(row.userId, 'user_1');
      expect(row.anonymousId, 'anon');
      expect(row.properties, '{"price":20}');
      expect(row.status, 'pending');
      expect(row.attempts, 0);
      expect(await db.metaDao.read(MetaKeys.trackedTotal), '1');
      expect(logs.at(LogLevel.debug), [
        'track("purchase", {price: 20}) queued',
      ]);
    },
  );

  test(
    'a time given (a call kept from before the start) is used, in UTC',
    () async {
      final events = recorder();
      final earlier = DateTime.utc(2026, 11, 3, 9, 40, 30);

      track(events, 'app_opened', at: earlier.toLocal());
      await events.idle;

      expect((await db.eventDao.all()).single.timestamp, earlier);
    },
  );

  test(
    '100 calls in one frame: all stored, in call order, no duplicates',
    () async {
      final events = recorder();

      for (var i = 0; i < 100; i++) {
        track(events, 'tap', properties: {'n': i});
      }
      // Nothing is written during the calls: the host never waits for disk.
      expect(await db.eventDao.all(), isEmpty);
      await events.idle;

      final rows = await db.eventDao.all();
      expect(rows.map((row) => row.properties), [
        for (var i = 0; i < 100; i++) '{"n":$i}',
      ]);
      expect(rows.map((row) => row.id).toSet(), hasLength(100));
      expect(await db.metaDao.read(MetaKeys.trackedTotal), '100');
    },
  );

  test('a burst is one transaction: a reader sees none or all', () async {
    final events = recorder();
    for (var i = 0; i < 50; i++) {
      track(events, 'tap');
    }

    final seen = <int>[];
    final subscription = db.eventDao
        .select(db.events)
        .watch()
        .listen((rows) => seen.add(rows.length));
    addTearDown(subscription.cancel);
    await events.idle;
    await pumpEventQueue();

    expect(seen, everyElement(anyOf(0, 50)));
    expect(seen.last, 50);
  });

  test('calls made while a drain runs are stored after it, in order', () async {
    final events = recorder();
    track(events, 'first');
    final firstDrain = events.idle;
    await Future<void>.delayed(Duration.zero);
    track(events, 'second');

    await firstDrain;
    await events.idle;

    final names = (await db.eventDao.all()).map((row) => row.name);
    expect(names, ['first', 'second']);
  });

  test('an invalid event is not stored; it is counted and logged', () async {
    final events = recorder();

    track(events, '');
    track(events, 'ok');
    await events.idle;

    expect((await db.eventDao.all()).map((row) => row.name), ['ok']);
    expect(await db.metaDao.read(MetaKeys.rejectedTotal), '1');
    expect(await db.metaDao.read(MetaKeys.trackedTotal), '1');
    expect(logs.at(LogLevel.warning), [
      'track("") rejected: the name is blank',
    ]);
  });

  test('past the limit, the oldest unsent go, counted', () async {
    final events = recorder(maxQueueSize: 3);

    for (final name in ['a', 'b', 'c', 'd', 'e']) {
      track(events, name);
    }
    await events.idle;

    expect((await db.eventDao.all()).map((row) => row.name), ['c', 'd', 'e']);
    expect(await db.metaDao.read(MetaKeys.droppedTotal), '2');
    expect(await db.metaDao.read(MetaKeys.trackedTotal), '5');
    expect(logs.at(LogLevel.warning), [
      'queue full: dropped the 2 oldest unsent events',
    ]);
  });

  test('meta writes and counters go through the same queue', () async {
    final events = recorder()
      ..enqueue(const SetMeta('k', 'v'))
      ..enqueue(const AddToCounter('n', 2))
      ..enqueue(const AddToCounter('n', 3))
      ..enqueue(const SetMeta('gone', 'x'))
      ..enqueue(const SetMeta('gone', null));
    await events.idle;

    expect(await db.metaDao.read('k'), 'v');
    expect(await db.metaDao.read('n'), '5');
    expect(await db.metaDao.read('gone'), isNull);
  });

  test('idle completes at once when nothing is queued', () async {
    await expectLater(recorder().idle, completes);
  });

  test('close stores what is queued, then refuses new writes', () async {
    final events = recorder();
    track(events, 'before');

    await events.close();
    track(events, 'after');
    await events.idle;

    expect((await db.eventDao.all()).map((row) => row.name), ['before']);
  });

  test('a write that fails is logged, and the queue carries on', () async {
    final events = recorder();
    // The same id twice: the second insert breaks the UNIQUE constraint.
    final broken = EventRecorder(
      database: db,
      maxQueueSize: 100,
      logger: logs.logger(),
      newId: () => 'same',
      clock: Clock.fixed(testNow),
    );
    broken.enqueue(const SetMeta('written_with_them', 'yes'));
    track(broken, 'one');
    track(broken, 'two');
    await broken.idle;

    // All or nothing: the meta write queued with them is rolled back too.
    expect(await db.eventDao.all(), isEmpty);
    expect(await db.metaDao.read('written_with_them'), isNull);
    expect(
      logs.at(LogLevel.error).single,
      startsWith('storing 3 queued writes failed'),
    );

    track(events, 'later');
    await events.idle;
    expect((await db.eventDao.all()).map((row) => row.name), ['later']);
  });
}
