import 'dart:async';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/scripted_transport.dart';
import '../helpers/sdk.dart';

void main() {
  test('watchStats: the counts and ids now, then after each change', () async {
    final db = TrackLiteDatabase.inMemory();
    // Offline: no automatic upload changes the counts under the test.
    final client = await openTestClient(
      database: db,
      config: testConfig(
        batchSize: 1,
        maxQueueSize: 2,
        networkMonitor: FakeNetworkMonitor(online: false),
      ),
    );
    addTearDown(client.shutdown);
    final stats = client.debug.watchStats();

    expect(
      await stats.first,
      const TrackLiteStats(anonymousId: 'id-1', isOnline: false),
    );

    client
      ..setUserId('user_123')
      ..track('a')
      ..track('b')
      ..track('c')
      ..track('');
    await client.idle;

    expect(
      await stats.first,
      const TrackLiteStats(
        anonymousId: 'id-1',
        userId: 'user_123',
        tracked: 3,
        pending: 2,
        dropped: 1,
        rejected: 1,
        isOnline: false,
      ),
    );
  });

  group('the live parts of the stats', () {
    test('online and uploading follow the monitor and the uploader', () async {
      final monitor = FakeNetworkMonitor();
      final transport = ScriptedTransport()..gate = Completer<void>();
      final client = await openTestClient(
        config: testConfig(transport: transport, networkMonitor: monitor),
      );
      addTearDown(client.shutdown);
      final seen = <(bool, bool)>[];
      final subscription = client.debug
          .watchStats()
          .map((s) => (s.isOnline, s.isUploading))
          .listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      client.track('tap');
      final flushing = client.flush();
      await pumpEventQueue();
      transport.gate!.complete();
      await flushing;
      monitor.online = false;
      await pumpEventQueue();

      expect(seen.first, (true, false));
      expect(seen, contains((true, true)));
      expect(seen.last, (false, false));
    });

    test('the next retry and the last upload', () async {
      final client = await openTestClient(
        config: testConfig(
          transport: ScriptedTransport([const ServerFailure(500)]),
        ),
      );
      addTearDown(client.shutdown);
      client.track('tap');

      await client.flush();
      final stats = await client.debug.watchStats().first;

      expect(stats.nextRetryAt, testNow.add(const Duration(minutes: 1)));
      expect(stats.lastUpload?.outcome, 'failed');
      expect(stats.lastUpload?.error, 'server error 500');
      expect(stats.lastUpload?.trigger, 'manual');
    });

    test('can be listened to more than once', () async {
      final client = await openTestClient();
      addTearDown(client.shutdown);
      final stats = client.debug.watchStats();

      await stats.first;
      await expectLater(stats.first, completes);
    });
  });

  test('recent events: newest first, any status, with their errors', () async {
    final client = await openTestClient(
      config: testConfig(
        transport: ScriptedTransport([
          const UploadResponse(accepted: 1),
          const ServerFailure(503),
        ]),
        batchSize: 1,
      ),
    );
    addTearDown(client.shutdown);
    client.track('first');
    await client.flush();
    client
      ..track('second')
      ..track('third');
    await client.flush();

    final recent = await client.debug.watchRecentEvents(limit: 2).first;

    expect(recent.map((e) => (e.name, e.status, e.attempts)), [
      ('third', EventStatus.pending, 0),
      ('second', EventStatus.pending, 1),
    ]);
    expect(recent.last.lastError, 'server error 503');
    expect(recent.last.nextAttemptAt, isNotNull);
  });

  test('uploads: the newest runs first, as records', () async {
    final client = await openTestClient();
    addTearDown(client.shutdown);
    client.track('a');
    await client.flush();
    await client.flush();

    final runs = await client.debug.watchUploads().first;

    expect(runs.map((r) => (r.trigger, r.outcome, r.events)), [
      ('manual', 'nothing', 0),
      ('manual', 'uploaded', 1),
    ]);
  });

  test('retryFailed: failed events back to pending, as if new', () async {
    final client = await openTestClient(
      config: testConfig(
        transport: ScriptedTransport([const RequestRejected(400, 'bad')]),
      ),
    );
    addTearDown(client.shutdown);
    client
      ..track('a')
      ..track('b');
    await client.flush();
    expect((await client.debug.watchStats().first).failed, 2);

    expect(await client.debug.retryFailed(), 2);

    final recent = await client.debug.watchRecentEvents().first;
    expect(recent.map((e) => (e.status, e.attempts, e.lastError)), [
      (EventStatus.pending, 0, null),
      (EventStatus.pending, 0, null),
    ]);
    expect(await client.debug.retryFailed(), 0);
    expect(await client.flush(), isA<Uploaded>());
  });

  test('retryFailed clears what a failure left: the attempts and an old '
      'retry wait', () async {
    final client = await openTestClient(
      config: testConfig(
        transport: ScriptedTransport([
          const ServerFailure(500),
          const RequestRejected(400, 'bad'),
        ]),
      ),
    );
    addTearDown(client.shutdown);
    client.track('a');
    await client.flush(); // 5xx: one attempt, a wait
    await client.flush(); // 400: failed, keeping both
    final failed = (await client.debug.watchRecentEvents().first).single;
    expect((failed.status, failed.attempts), (EventStatus.failed, 1));
    expect(failed.nextAttemptAt, isNotNull);

    await client.debug.retryFailed();

    final retried = (await client.debug.watchRecentEvents().first).single;
    expect((retried.status, retried.attempts), (EventStatus.pending, 0));
    expect(retried.nextAttemptAt, isNull);
  });

  group('the stats pick the right rows', () {
    test('the earliest retry of several, whatever the row order', () async {
      final db = TrackLiteDatabase.inMemory();
      final client = await openTestClient(
        database: db,
        // Offline: nothing uploads and moves the retry times.
        config: testConfig(networkMonitor: FakeNetworkMonitor(online: false)),
      );
      addTearDown(client.shutdown);
      client
        ..track('later')
        ..track('sooner');
      await client.idle;
      final later = testNow.add(const Duration(minutes: 8));
      final sooner = testNow.add(const Duration(minutes: 2));
      for (final (name, at) in [('later', later), ('sooner', sooner)]) {
        await (db.update(db.events)..where((row) => row.name.equals(name)))
            .write(EventsCompanion(nextAttemptAt: Value(at)));
      }

      final stats = await client.debug.watchStats().first;

      expect(stats.nextRetryAt, sooner);
    });

    test('the last upload is the newest run', () async {
      final client = await openTestClient();
      addTearDown(client.shutdown);
      client.track('a');
      await client.flush();
      await client.flush();

      final stats = await client.debug.watchStats().first;
      expect(stats.lastUpload?.outcome, 'nothing');
    });

    test('a run that changes only the log still updates the stats', () async {
      final client = await openTestClient();
      addTearDown(client.shutdown);
      final seen = <String?>[];
      final subscription = client.debug
          .watchStats()
          .map((s) => s.lastUpload?.outcome)
          .listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await client.flush(); // nothing to send: only the log is written
      await pumpEventQueue();

      expect(seen.last, 'nothing');
    });
  });

  test('UploadRecord: equality and words', () {
    final at = DateTime.utc(2026);
    final record = UploadRecord(
      trigger: 'manual',
      startedAt: at,
      finishedAt: at,
      outcome: 'failed',
      error: 'server error 500',
    );

    expect(
      record,
      UploadRecord(
        trigger: 'manual',
        startedAt: at,
        finishedAt: at,
        outcome: 'failed',
        error: 'server error 500',
      ),
    );
    expect(record.toString(), contains('server error 500'));
  });

  test('stats equality, and every count defaults to 0', () {
    const stats = TrackLiteStats(anonymousId: 'a');

    expect(stats.tracked + stats.pending + stats.sending, 0);
    expect(stats.sent + stats.failed + stats.dropped + stats.rejected, 0);
    expect(stats, const TrackLiteStats(anonymousId: 'a'));
    expect(stats.hashCode, const TrackLiteStats(anonymousId: 'a').hashCode);
    expect(stats, isNot(const TrackLiteStats(anonymousId: 'a', failed: 1)));
    expect(stats.toString(), contains('anonymousId: a'));
  });
}
