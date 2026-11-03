import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/debug/tracklite_debug.dart';
import 'package:tracklite/src/recording/event_recorder.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/upload/upload_manager.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

import '../helpers/scripted_transport.dart';
import '../helpers/sdk.dart';

void main() {
  late TrackLiteDatabase db;
  late EventRecorder recorder;
  late LogRecorder logs;
  late DateTime now;
  late SequentialIds ids;

  setUp(() {
    db = TrackLiteDatabase.inMemory();
    logs = LogRecorder();
    now = testNow;
    ids = SequentialIds();
    recorder = EventRecorder(
      database: db,
      maxQueueSize: 10000,
      logger: logs.logger(),
      newId: ids.call,
      clock: Clock(() => now),
    );
  });
  tearDown(() => db.close());

  late FakeNetworkMonitor monitor;
  setUp(() => monitor = FakeNetworkMonitor());

  UploadManager uploader(
    AnalyticsTransport transport, {
    int batchSize = 20,
    int maxRetries = 5,
  }) => UploadManager(
    database: db,
    recorder: recorder,
    transport: transport,
    monitor: monitor,
    apiKey: 'demo_key',
    batchSize: batchSize,
    maxRetries: maxRetries,
    retry: const RetryPolicy(),
    logger: logs.logger(),
    newId: () => 'claim-${ids()}',
    clock: Clock(() => now),
  );

  void track(int count, {String name = 'tap'}) {
    for (var i = 0; i < count; i++) {
      recorder.record(name, {'n': i}, userId: null, anonymousId: 'anon');
    }
  }

  Future<List<String>> statuses() async => [
    for (final row in await db.eventDao.all()) row.status,
  ];

  Future<String?> meta(String name) => db.metaDao.read(name);

  group('batching', () {
    test(
      '100 events, batches of 20: 5 requests, oldest first, all sent',
      () async {
        final transport = ScriptedTransport();
        track(100);

        final result = await uploader(transport).upload(UploadTrigger.manual);

        expect(
          result,
          isA<Uploaded>()
              .having((r) => r.events, 'events', 100)
              .having((r) => r.batches, 'batches', 5),
        );
        expect(transport.batches.map((b) => b.events.length), [
          20,
          20,
          20,
          20,
          20,
        ]);
        expect(transport.batches.first.events.first.properties, {'n': 0});
        expect(transport.batches.last.events.last.properties, {'n': 99});
        expect(await statuses(), everyElement('sent'));
        expect(await meta(MetaKeys.sentTotal), '100');
      },
    );

    test('a batch carries the key, the time and the SDK version', () async {
      final transport = ScriptedTransport();
      track(1);

      await uploader(transport).upload(UploadTrigger.manual);

      final batch = transport.batches.single;
      expect(batch.apiKey, 'demo_key');
      expect(batch.sentAt, testNow);
      expect(batch.libraryVersion, TrackLite.version);
    });

    test('nothing stored: NothingToSend, and no request', () async {
      final transport = ScriptedTransport();

      expect(
        await uploader(transport).upload(UploadTrigger.manual),
        isA<NothingToSend>(),
      );
      expect(transport.batches, isEmpty);
    });

    test('what was tracked just before is stored first, then sent', () async {
      final transport = ScriptedTransport();
      track(3);
      // Not stored yet: the recorder writes a microtask later.
      expect(await db.eventDao.all(), isEmpty);

      final result = await uploader(transport).upload(UploadTrigger.manual);

      expect(result, isA<Uploaded>().having((r) => r.events, 'events', 3));
    });

    test('through the real fake server, end to end', () async {
      final server = instantServer();
      track(45);

      await uploader(server).upload(UploadTrigger.manual);

      expect(server.stats, const FakeServerStats(requests: 3, accepted: 45));
    });
  });

  group('a failure stops the run, and keeps the events', () {
    for (final (kind, error, status, result) in [
      ('unreachable', const ServerUnreachable(), 'pending', isA<Failed>()),
      ('a 500', const ServerFailure(500), 'pending', isA<Failed>()),
      ('a 401', const ApiKeyRejected(), 'pending', isA<Unauthorized>()),
      (
        'a 400 (refused for good)',
        const RequestRejected(400, 'bad batch'),
        'failed',
        isA<Failed>(),
      ),
    ]) {
      test(kind, () async {
        final transport = ScriptedTransport([error]);
        track(30);

        final outcome = await uploader(transport).upload(UploadTrigger.manual);

        expect(outcome, result);
        // Only the first batch was tried: a failing server isn't sent more.
        expect(transport.batches, hasLength(1));
        final rows = await db.eventDao.all();
        expect(rows.take(20).map((r) => r.status), everyElement(status));
        expect(
          rows.take(20).map((r) => r.lastError),
          everyElement(error.message),
        );
        expect(rows.skip(20).map((r) => r.status), everyElement('pending'));
        expect(rows.map((r) => r.claimToken), everyElement(isNull));
        expect(await meta(MetaKeys.sentTotal), isNull);
      });
    }

    test('Failed says why and how many are waiting', () async {
      track(30);

      final result = await uploader(
        ScriptedTransport([const ServerFailure(503)]),
      ).upload(UploadTrigger.manual);

      expect(
        result,
        isA<Failed>()
            .having((r) => r.reason, 'reason', 'server error 503')
            .having((r) => r.remaining, 'remaining', 30),
      );
    });

    test('a batch sent before the failure stays sent', () async {
      final transport = ScriptedTransport([
        const UploadResponse(accepted: 20),
        const ServerFailure(500),
      ]);
      track(50);

      final result = await uploader(transport).upload(UploadTrigger.manual);

      expect(result, isA<Failed>().having((r) => r.remaining, 'remaining', 30));
      final counts = <String, int>{};
      for (final status in await statuses()) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
      expect(counts, {'sent': 20, 'pending': 30});
      expect(await meta(MetaKeys.sentTotal), '20');
    });

    test('a transport that throws something else: released, Failed', () async {
      track(2);

      final result = await uploader(
        ScriptedTransport([StateError('bug in a custom transport')]),
      ).upload(UploadTrigger.manual);

      expect(
        result,
        isA<Failed>().having(
          (r) => r.reason,
          'reason',
          'transport error: Bad state: bug in a custom transport',
        ),
      );
      expect(await statuses(), ['pending', 'pending']);
      expect(
        logs.at(LogLevel.error).single,
        startsWith('the transport failed'),
      );
    });
  });

  group('at least once', () {
    test('a crash after the server stored a batch: resent, the server drops '
        'the duplicates, the events end sent', () async {
      final server = instantServer();
      track(5);
      await recorder.idle;
      // The app sent the batch and died before writing `sent`: the server
      // has the events, and the rows are still claimed.
      final claimed = await db.eventDao.claim(
        token: 'died',
        now: testNow,
        limit: 5,
      );
      await server.upload(
        UploadBatch(
          apiKey: 'demo_key',
          sentAt: testNow,
          libraryVersion: TrackLite.version,
          events: [
            for (final row in claimed)
              TrackLiteEvent(
                id: row.id,
                name: row.name,
                timestamp: row.timestamp,
                anonymousId: row.anonymousId,
                properties: const {},
                status: EventStatus.sending,
              ),
          ],
        ),
      );

      // Six minutes later the app runs again.
      now = testNow.add(const Duration(minutes: 6));
      final result = await uploader(server).upload(UploadTrigger.manual);

      expect(result, isA<Uploaded>().having((r) => r.events, 'events', 5));
      expect(await statuses(), everyElement('sent'));
      expect(server.stats.accepted, 5);
      expect(server.stats.duplicates, 5);
      expect(
        logs.at(LogLevel.warning),
        contains('5 events back to pending: their upload died'),
      );
    });

    test('a claim younger than 5 minutes is left alone (still in flight '
        'somewhere)', () async {
      track(1);
      await recorder.idle;
      await db.eventDao.claim(token: 'live', now: testNow, limit: 1);
      now = testNow.add(const Duration(minutes: 4));

      final result = await uploader(ScriptedTransport())
          .upload(UploadTrigger.manual);

      expect(result, isA<NothingToSend>());
      expect(await statuses(), ['sending']);
    });
  });

  group('single-flight', () {
    test(
      'a second upload while one runs joins it: one set of requests',
      () async {
        final transport = ScriptedTransport()..gate = Completer<void>();
        track(10);
        final uploads = uploader(transport);

        final first = uploads.upload(UploadTrigger.manual);
        final second = uploads.upload(UploadTrigger.interval);
        expect(uploads.isUploading, isTrue);
        await pumpEventQueue();
        transport.gate!.complete();

        expect(await first, same(await second));
        expect(transport.batches, hasLength(1));
        expect(uploads.isUploading, isFalse);
      },
    );

    test('after a run ends, the next one starts afresh', () async {
      final transport = ScriptedTransport();
      final uploads = uploader(transport);
      track(1);
      await uploads.upload(UploadTrigger.manual);

      track(1);
      final result = await uploads.upload(UploadTrigger.manual);

      expect(result, isA<Uploaded>().having((r) => r.events, 'events', 1));
      expect(transport.batches, hasLength(2));
    });

    test('close waits for the run in flight', () async {
      final transport = ScriptedTransport()..gate = Completer<void>();
      track(1);
      final uploads = uploader(transport);
      final run = uploads.upload(UploadTrigger.manual);

      var closed = false;
      final closing = uploads.close().then((_) => closed = true);
      await pumpEventQueue();
      expect(closed, isFalse);

      transport.gate!.complete();
      await closing;
      expect(await run, isA<Uploaded>());
    });
  });

  test('sent events are kept a day, then pruned; the total stays', () async {
    final uploads = uploader(ScriptedTransport());
    track(2);
    await uploads.upload(UploadTrigger.manual);

    now = testNow.add(const Duration(hours: 25));
    track(1);
    await uploads.upload(UploadTrigger.manual);

    final rows = await db.eventDao.all();
    expect(rows, hasLength(1));
    expect(await meta(MetaKeys.sentTotal), '3');
    // The stats count every event ever sent, not the rows still kept.
    final stats = await DatabaseDebug(
      db,
      watchOnline: () => Stream.value(true),
      watchUploading: () => Stream.value(false),
    ).watchStats().first;
    expect(stats.sent, 3);
  });

  group('the upload log', () {
    test('one entry per run: trigger, times, outcome, counts', () async {
      final uploads = uploader(
        ScriptedTransport([
          const UploadResponse(accepted: 20),
          const ServerFailure(500),
        ]),
      );
      track(25);
      await uploads.upload(UploadTrigger.manual);
      // The failed batch waits its minute of backoff.
      now = now.add(const Duration(minutes: 1));
      await uploads.upload(UploadTrigger.interval);
      await uploads.upload(UploadTrigger.threshold);

      final runs = await db.uploadDao.newest();
      expect(
        runs.map((r) => (r.trigger, r.outcome, r.batches, r.events, r.error)),
        [
          ('threshold', 'nothing', 0, 0, null),
          ('interval', 'uploaded', 1, 5, null),
          ('manual', 'failed', 1, 20, 'server error 500'),
        ],
      );
      expect(runs.last.startedAt, testNow);
    });

    test('a rejected key is logged as unauthorized', () async {
      track(1);
      await uploader(ScriptedTransport([const ApiKeyRejected()]))
          .upload(UploadTrigger.manual);

      final run = (await db.uploadDao.newest()).single;
      expect(run.outcome, 'unauthorized');
      expect(run.error, 'the API key was rejected');
    });
  });

  test(
    'a database that fails mid-run: Failed, logged, nothing thrown',
    () async {
      track(1);
      await recorder.idle;
      final uploads = uploader(ScriptedTransport());
      await db.customStatement('DROP TABLE events');

      final result = await uploads.upload(UploadTrigger.manual);

      expect(result, isA<Failed>());
      expect(logs.at(LogLevel.error).first, startsWith('upload failed'));
      // The run still reached the log.
      expect((await db.uploadDao.newest()).single.outcome, 'failed');
    },
  );

  group('retries', () {
    Future<List<(String, int, DateTime?)>> retryState() async => [
      for (final row in await db.eventDao.all())
        (row.status, row.attempts, row.nextAttemptAt),
    ];

    test('a 5xx: +1 attempt, then the backoff: 1 min, then 2', () async {
      final transport = ScriptedTransport([
        const ServerFailure(500),
        const ServerFailure(503),
      ]);
      final uploads = uploader(transport);
      track(1);

      await uploads.upload(UploadTrigger.manual);
      expect(await retryState(), [
        ('pending', 1, testNow.add(const Duration(minutes: 1))),
      ]);

      // Not due yet: an automatic run sends nothing.
      expect(
        await uploads.upload(UploadTrigger.interval),
        isA<NothingToSend>(),
      );
      expect(transport.batches, hasLength(1));

      now = testNow.add(const Duration(minutes: 1));
      await uploads.upload(UploadTrigger.retryDue);
      expect(await retryState(), [
        ('pending', 2, now.add(const Duration(minutes: 2))),
      ]);
    });

    test('past maxRetries: failed, kept, with the last error', () async {
      final uploads = uploader(
        ScriptedTransport([
          for (var i = 0; i < 3; i++) const ServerFailure(500),
        ]),
        maxRetries: 2,
      );
      track(1);

      for (var i = 0; i < 3; i++) {
        await uploads.upload(UploadTrigger.manual, ignoreBackoff: true);
      }

      final row = (await db.eventDao.all()).single;
      expect(
        (row.status, row.attempts, row.nextAttemptAt),
        ('failed', 3, null),
      );
      expect(row.lastError, 'server error 500');
      expect(
        logs.at(LogLevel.warning),
        contains('1 events failed: more than 2 server errors'),
      );
    });

    test('maxRetries 0: the first server error is final', () async {
      final uploads = uploader(
        ScriptedTransport([const ServerFailure(500)]),
        maxRetries: 0,
      );
      track(1);

      await uploads.upload(UploadTrigger.manual);

      expect(await statuses(), ['failed']);
    });

    test('each event waits its own backoff in a mixed batch', () async {
      final transport = ScriptedTransport([
        const ServerFailure(500),
        const ServerFailure(500),
      ]);
      final uploads = uploader(transport);
      track(1, name: 'old');
      await uploads.upload(UploadTrigger.manual);
      track(1, name: 'new');

      await uploads.upload(UploadTrigger.manual, ignoreBackoff: true);

      expect(await retryState(), [
        ('pending', 2, testNow.add(const Duration(minutes: 2))),
        ('pending', 1, testNow.add(const Duration(minutes: 1))),
      ]);
    });

    test('unreachable: no attempt counted, no wait', () async {
      final uploads = uploader(
        ScriptedTransport([
          for (var i = 0; i < 10; i++) const ServerUnreachable(),
        ]),
        maxRetries: 2,
      );
      track(1);

      for (var i = 0; i < 10; i++) {
        await uploads.upload(UploadTrigger.interval);
      }

      expect(await retryState(), [('pending', 0, null)]);
    });

    test('a 401: no attempt, and automatic uploads pause', () async {
      final uploads = uploader(ScriptedTransport([const ApiKeyRejected()]));
      track(1);
      expect(uploads.pausedByRejectedKey, isFalse);

      await uploads.upload(UploadTrigger.manual);

      expect(uploads.pausedByRejectedKey, isTrue);
      expect(await retryState(), [('pending', 0, null)]);
    });

    test('the earliest retry time and the due count', () async {
      final uploads = uploader(
        ScriptedTransport([const ServerFailure(500)]),
        batchSize: 1,
      );
      track(3);
      expect(await uploads.nextRetryAt(), isNull);
      expect(await uploads.dueCount(), 3);

      await uploads.upload(UploadTrigger.manual);

      expect(
        await uploads.nextRetryAt(),
        testNow.add(const Duration(minutes: 1)),
      );
      expect(await uploads.dueCount(), 2);
    });
  });

  group('offline', () {
    test('nothing is attempted, and the events are untouched', () async {
      final transport = ScriptedTransport();
      monitor.online = false;
      track(3);

      final result = await uploader(transport).upload(UploadTrigger.manual);

      expect(result, isA<Offline>());
      expect(transport.batches, isEmpty);
      expect(await statuses(), everyElement('pending'));
    });

    test('a manual flush offline is logged; an automatic one is not', () async {
      monitor.online = false;
      final uploads = uploader(ScriptedTransport());

      await uploads.upload(UploadTrigger.manual);
      await uploads.upload(UploadTrigger.reconnect);

      final runs = await db.uploadDao.newest();
      expect(runs.map((r) => (r.trigger, r.outcome)), [('manual', 'offline')]);
    });
  });
}
