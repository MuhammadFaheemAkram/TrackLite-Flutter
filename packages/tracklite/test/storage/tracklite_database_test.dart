import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

import '../helpers/sdk.dart';

void main() {
  late TrackLiteDatabase db;

  setUp(() => db = TrackLiteDatabase.inMemory());
  tearDown(() => db.close());

  EventsCompanion event(
    String id, {
    String status = 'pending',
    String properties = '{}',
    DateTime? timestamp,
    Value<String?> claimToken = const Value.absent(),
    Value<DateTime?> claimedAt = const Value.absent(),
    Value<DateTime?> sentAt = const Value.absent(),
  }) => EventsCompanion.insert(
    id: id,
    name: 'screen_opened',
    timestamp: timestamp ?? testNow,
    anonymousId: 'anon',
    properties: properties,
    status: status,
    claimToken: claimToken,
    claimedAt: claimedAt,
    sentAt: sentAt,
  );

  // A schema change must bump `schemaVersion` and export the new version
  // (`fvm dart run drift_dev make-migrations`): an SDK's database upgrades
  // on its users' devices, so each version must be kept to migrate from.
  test('the current schema version is exported, with every table', () {
    final file = File(
      'drift_schemas/tracklite_database/'
      'drift_schema_v${db.schemaVersion}.json',
    );
    expect(file.existsSync(), isTrue, reason: 'run make-migrations');

    final schema = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final exported = [
      for (final entity in schema['entities'] as List<dynamic>)
        if ((entity as Map<String, dynamic>)['type'] == 'table')
          (entity['data'] as Map<String, dynamic>)['name'],
    ];
    expect(
      exported,
      unorderedEquals(db.allTables.map((t) => t.actualTableName)),
    );
  });

  group('events: the CHECKs refuse a broken row', () {
    for (final (rule, row) in [
      ('an unknown status', event('e', status: 'lost')),
      ('properties that are not an object', event('e', properties: '[1]')),
      ('a local timestamp', event('e', timestamp: DateTime(2026))),
      ('sending without a claim', event('e', status: 'sending')),
      (
        'a claim while pending',
        event('e', claimToken: const Value('c'), claimedAt: Value(testNow)),
      ),
      ('sent without a time', event('e', status: 'sent')),
      ('a send time while pending', event('e', sentAt: Value(testNow))),
      ('a blank id', event(' ')),
    ]) {
      test(rule, () async {
        await expectLater(
          db.eventDao.insertAll([row]),
          throwsA(isA<Exception>()),
        );
      });
    }

    test('a valid sending and a valid sent row are accepted', () async {
      await db.eventDao.insertAll([
        event(
          'a',
          status: 'sending',
          claimToken: const Value('c'),
          claimedAt: Value(testNow),
        ),
        event('b', status: 'sent', sentAt: Value(testNow)),
      ]);

      expect(await db.eventDao.all(), hasLength(2));
    });

    test('an id is stored once', () async {
      await db.eventDao.insertAll([event('same')]);

      await expectLater(
        db.eventDao.insertAll([event('same')]),
        throwsA(isA<Exception>()),
      );
    });
  });

  test('rows keep their insertion order in seq', () async {
    await db.eventDao.insertAll([event('c'), event('a'), event('b')]);

    final rows = await db.eventDao.all();
    expect(rows.map((row) => row.id), ['c', 'a', 'b']);
    expect(rows.map((row) => row.seq), [1, 2, 3]);
  });

  group('dropping the oldest unsent', () {
    test('skips sent rows and the ones in flight', () async {
      await db.eventDao.insertAll([
        event('sent', status: 'sent', sentAt: Value(testNow)),
        event(
          'flying',
          status: 'sending',
          claimToken: const Value('c'),
          claimedAt: Value(testNow),
        ),
        event('failed', status: 'failed'),
        event('p1'),
        event('p2'),
      ]);
      expect(await db.eventDao.unsentCount(), 4);

      expect(await db.eventDao.dropOldestUnsent(2), 2);

      final left = await db.eventDao.all();
      expect(left.map((row) => row.id), ['sent', 'flying', 'p2']);
    });

    test('says how many went when there were fewer', () async {
      await db.eventDao.insertAll([event('p1')]);

      expect(await db.eventDao.dropOldestUnsent(5), 1);
    });
  });

  group('meta', () {
    test('write, read, overwrite and remove', () async {
      expect(await db.metaDao.read('k'), isNull);

      await db.metaDao.write('k', 'one');
      await db.metaDao.write('k', 'two');
      expect(await db.metaDao.read('k'), 'two');

      await db.metaDao.remove('k');
      expect(await db.metaDao.read('k'), isNull);
    });

    test('a counter starts at 0 and adds up', () async {
      await db.metaDao.increment('n', 3);
      await db.metaDao.increment('n', 4);

      expect(await db.metaDao.read('n'), '7');
    });
  });

  group('claims', () {
    Future<void> pending(List<String> ids, {DateTime? retryAt}) =>
        db.eventDao.insertAll([
          for (final id in ids)
            event(id).copyWith(nextAttemptAt: Value(retryAt)),
        ]);

    test('take the oldest due, up to the limit, in one go', () async {
      await pending(['a', 'b', 'c']);

      final claimed = await db.eventDao.claim(
        token: 't1',
        now: testNow,
        limit: 2,
      );

      expect(claimed.map((row) => (row.id, row.status, row.claimToken)), [
        ('a', 'sending', 't1'),
        ('b', 'sending', 't1'),
      ]);
      expect(claimed.first.claimedAt, testNow);
    });

    test('a second claim gets the rest, never the same events', () async {
      await pending(['a', 'b', 'c']);
      await db.eventDao.claim(token: 't1', now: testNow, limit: 2);

      final second = await db.eventDao.claim(
        token: 't2',
        now: testNow,
        limit: 2,
      );

      expect(second.map((row) => row.id), ['c']);
      expect(
        await db.eventDao.claim(token: 't3', now: testNow, limit: 2),
        isEmpty,
      );
    });

    test('a retry waits for its time, unless backoff is ignored', () async {
      final later = testNow.add(const Duration(minutes: 1));
      await pending(['waiting'], retryAt: later);
      await pending(['due'], retryAt: testNow);

      final auto = await db.eventDao.claim(token: 't1', now: testNow, limit: 9);
      expect(auto.map((row) => row.id), ['due']);

      final manual = await db.eventDao.claim(
        token: 't2',
        now: testNow,
        limit: 9,
        ignoreBackoff: true,
      );
      expect(manual.map((row) => row.id), ['waiting']);
    });

    test('an expired claim goes back to pending; a recent one stays', () async {
      await pending(['old', 'recent']);
      await db.eventDao.claim(
        token: 'dead',
        now: testNow.subtract(const Duration(minutes: 6)),
        limit: 1,
      );
      await db.eventDao.claim(token: 'live', now: testNow, limit: 1);

      final released = await db.eventDao.releaseExpiredClaims(
        testNow.subtract(const Duration(minutes: 5)),
      );

      expect(released, 1);
      final rows = await db.eventDao.all();
      expect(rows.map((row) => (row.id, row.status, row.claimToken)), [
        ('old', 'pending', null),
        ('recent', 'sending', 'live'),
      ]);
    });

    test('sent, released and failed claims leave no claim behind', () async {
      await pending(['a', 'b', 'c']);
      for (final (token, id) in [('t1', 'a'), ('t2', 'b'), ('t3', 'c')]) {
        await db.eventDao.claim(token: token, now: testNow, limit: 1);
        expect(
          (await db.eventDao.all()).firstWhere((r) => r.id == id).status,
          'sending',
        );
      }

      expect(await db.eventDao.markSent('t1', testNow), 1);
      expect(await db.eventDao.release('t2', 'server error 500'), 1);
      expect(await db.eventDao.markFailed('t3', 'bad batch'), 1);

      final rows = await db.eventDao.all();
      expect(rows.map((r) => (r.status, r.claimToken, r.sentAt, r.lastError)), [
        ('sent', null, testNow, null),
        ('pending', null, null, 'server error 500'),
        ('failed', null, null, 'bad batch'),
      ]);
      expect(await db.eventDao.waitingCount(), 1);
    });

    test('sent events older than the cut-off are pruned', () async {
      await db.eventDao.insertAll([
        event(
          'old',
          status: 'sent',
          sentAt: Value(testNow.subtract(const Duration(hours: 25))),
        ),
        event('new', status: 'sent', sentAt: Value(testNow)),
        event('waiting'),
      ]);

      expect(
        await db.eventDao.pruneSent(
          testNow.subtract(const Duration(hours: 24)),
        ),
        1,
      );
      expect((await db.eventDao.all()).map((r) => r.id), ['new', 'waiting']);
    });
  });

  group('the upload log', () {
    UploadsCompanion run(int n) => UploadsCompanion.insert(
      trigger: 'manual',
      startedAt: testNow,
      finishedAt: testNow,
      outcome: 'uploaded',
      events: Value(n),
    );

    test('keeps the newest 100 runs', () async {
      for (var i = 1; i <= 103; i++) {
        await db.uploadDao.add(run(i));
      }

      // Every row, not `newest()`: it reads at most 100 anyway.
      expect(await db.select(db.uploads).get(), hasLength(100));
      final runs = await db.uploadDao.newest();
      expect(runs, hasLength(100));
      expect(runs.first.events, 103);
      expect(runs.last.events, 4);
    });

    test('refuses an unknown outcome', () async {
      await expectLater(
        db.uploadDao.add(run(1).copyWith(outcome: const Value('lost'))),
        throwsA(isA<Exception>()),
      );
    });
  });
}
