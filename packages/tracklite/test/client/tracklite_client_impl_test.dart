import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/sdk.dart';

void main() {
  late LogRecorder logs;
  late TrackLiteDatabase db;

  setUp(() {
    logs = LogRecorder();
    db = TrackLiteDatabase.inMemory();
  });

  Future<TrackLiteClientImpl> open({bool debugMode = true}) => openTestClient(
    config: TrackLiteConfig(apiKey: 'demo_key', debugMode: debugMode),
    database: db,
    logs: logs,
  );

  test('create validates the config first', () {
    expect(
      () => TrackLiteClient.create(const TrackLiteConfig(apiKey: ' ')),
      throwsArgumentError,
    );
  });

  test('a first start has an anonymous id and no user', () async {
    final client = await open();

    expect(client.anonymousId, 'id-1');
    expect(client.userId, isNull);
  });

  test('track stores the event with the identity at the time', () async {
    final client = await open();

    client
      ..track('screen_opened', properties: {'screen': 'Home'})
      ..setUserId('user_123')
      ..track('purchase');
    await client.idle;

    final rows = await db.eventDao.all();
    expect(rows.map((row) => (row.name, row.userId, row.anonymousId)), [
      ('screen_opened', null, 'id-1'),
      ('purchase', 'user_123', 'id-1'),
    ]);
    expect(await db.metaDao.read(MetaKeys.userId), 'user_123');
  });

  test('clearUser: later events have no user and a new anonymous id', () async {
    final client = await open()
      ..setUserId('user_123')
      ..clearUser()
      ..track('after');
    await client.idle;

    final row = (await db.eventDao.all()).single;
    expect(row.userId, isNull);
    expect(row.anonymousId, 'id-2');
    expect(client.anonymousId, 'id-2');
  });

  test('a blank or overlong user id is ignored, with a warning', () async {
    final client = await open()
      ..setUserId('  ')
      ..setUserId('u' * 256);

    expect(client.userId, isNull);
    expect(logs.at(LogLevel.warning), [
      'setUserId("  ") ignored: a user id is 1–255 characters',
      'setUserId("${'u' * 256}") ignored: a user id is 1–255 characters',
    ]);
    client.setUserId('u' * 255);
    expect(client.userId, 'u' * 255);
  });

  test('flush waits for the writes, and has nothing to send yet', () async {
    final client = await open()
      ..track('tap');
    expect(client.isIdle, isFalse);

    expect(await client.flush(), isA<NothingToSend>());

    // Nothing still pending the moment flush returns (a read through the
    // database alone would queue behind the write and pass anyway).
    expect(client.isIdle, isTrue);
    expect(await db.eventDao.all(), hasLength(1));
  });

  group('shutdown', () {
    test('stores what was tracked, then closes the file', () async {
      final dir = Directory.systemTemp.createTempSync('tracklite');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/tracklite.sqlite');
      final client =
          await openTestClient(
              database: TrackLiteDatabase(NativeDatabase(file)),
              logs: logs,
            )
            ..track('last');

      await client.shutdown();

      expect(client.isClosed, isTrue);
      expect(await client.flush(), isA<NotInitialized>());
      final reopened = TrackLiteDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      expect((await reopened.eventDao.all()).map((row) => row.name), ['last']);
    });

    test('later calls are ignored, with a warning each', () async {
      final client = await open();
      await client.shutdown();
      logs.lines.clear();

      client
        ..track('late')
        ..setUserId('u')
        ..clearUser();

      expect(logs.at(LogLevel.warning), [
        'track("late") after shutdown(): ignored',
        'setUserId after shutdown(): ignored',
        'clearUser after shutdown(): ignored',
      ]);
      await client.shutdown();
    });
  });

  test('without debug mode, nothing is logged', () async {
    final client = await open(debugMode: false)
      ..track('a')
      ..track('')
      ..setUserId('u');
    await client.shutdown();
    client.track('late');

    expect(logs.lines, isEmpty);
  });

  test('if the database can\'t open, the session runs in memory', () async {
    final broken = TrackLiteDatabase(
      NativeDatabase.memory(setup: (_) => throw StateError('disk full')),
    );

    final client = await openTestClient(database: broken, logs: logs)
      ..track('kept');
    await client.idle;

    expect(
      logs.at(LogLevel.error).single,
      'opening the event database failed: events are kept in memory for '
      'this session: Bad state: disk full',
    );
    expect(await client.database.eventDao.all(), hasLength(1));
    await client.shutdown();
  });

  test('an error inside a call is logged, never thrown at the app', () async {
    final client = await TrackLiteClientImpl.open(
      const TrackLiteConfig(apiKey: 'demo_key', debugMode: true),
      database: db,
      logger: TrackLiteLogger(
        enabled: true,
        sink: (level, message, {error, stackTrace}) {
          // The debug line fails (a broken sink); the error line must still
          // arrive and nothing escape.
          if (level == LogLevel.debug) throw StateError('sink broke');
          logs.lines.add((level, '$message: $error'));
        },
      ),
    );

    expect(() => client.setUserId('u'), returnsNormally);
    expect(logs.at(LogLevel.error), [
      'setUserId failed: Bad state: sink broke',
    ]);
  });
}
