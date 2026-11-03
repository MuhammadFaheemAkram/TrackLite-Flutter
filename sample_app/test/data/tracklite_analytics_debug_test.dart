import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/data/analytics/tracklite_analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

import '../helpers/fake_client.dart';

void main() {
  late FakeClient client;
  late TrackLiteAnalyticsDebug debug;
  final at = DateTime.utc(2026, 11, 4, 9, 41);

  setUp(() {
    client = FakeClient();
    debug = TrackLiteAnalyticsDebug(client);
  });

  UploadRecord record(String outcome, {String? error}) => UploadRecord(
    trigger: 'manual',
    startedAt: at,
    finishedAt: at,
    outcome: outcome,
    events: 2,
    error: error,
  );

  test("the queue: the SDK's stats, field by field", () async {
    final queue = debug.watchQueue().first;
    client.fakeDebug.stats.add(
      TrackLiteStats(
        anonymousId: 'anon',
        userId: 'user_123',
        tracked: 9,
        pending: 2,
        sending: 3,
        sent: 1,
        failed: 1,
        dropped: 4,
        rejected: 5,
        nextRetryAt: at,
        lastUpload: record('uploaded'),
        isUploading: true,
      ),
    );

    expect(
      await queue,
      QueueStats(
        anonymousId: 'anon',
        userId: 'user_123',
        tracked: 9,
        pending: 2,
        sending: 3,
        sent: 1,
        failed: 1,
        dropped: 4,
        rejected: 5,
        nextRetryAt: at,
        lastUpload: UploadRun(
          trigger: 'manual',
          finishedAt: at,
          outcome: UploadOutcome.uploaded,
          events: 2,
        ),
        uploading: true,
      ),
    );
  });

  test('recent events: each status in the app\'s words', () async {
    final recent = debug.watchRecentEvents().first;
    client.fakeDebug.recent.add([
      for (final status in EventStatus.values)
        TrackLiteEvent(
          id: status.name,
          name: 'tap',
          timestamp: at,
          anonymousId: 'a',
          properties: const {'screen': 'shop', 'n': 2},
          status: status,
          attempts: 2,
          nextAttemptAt: at,
          lastError: 'server error 500',
        ),
    ]);

    final events = await recent;
    expect(events.map((e) => e.state), EventState.values);
    expect(
      events.first,
      RecentEvent(
        id: 'pending',
        name: 'tap',
        trackedAt: at,
        state: EventState.pending,
        summary: 'screen: shop, n: 2',
        attempts: 2,
        retryAt: at,
        lastError: 'server error 500',
      ),
    );
  });

  test('uploads: every outcome the SDK logs', () async {
    final runs = debug.watchUploads().first;
    client.fakeDebug.uploads.add([
      for (final outcome in [
        'uploaded',
        'nothing',
        'offline',
        'failed',
        'unauthorized',
      ])
        record(outcome),
    ]);

    expect((await runs).map((r) => r.outcome), [
      UploadOutcome.uploaded,
      UploadOutcome.nothing,
      UploadOutcome.offline,
      UploadOutcome.failed,
      UploadOutcome.keyRejected,
    ]);
  });

  group("flush: each of the SDK's results in the app's words", () {
    for (final (result, outcome) in [
      (
        const Uploaded(events: 40, batches: 2),
        const FlushOutcome.sent(events: 40, requests: 2),
      ),
      (const NothingToSend(), const FlushOutcome.nothingToSend()),
      (const Offline(), const FlushOutcome.offline()),
      (
        const Failed(reason: 'server error 500', remaining: 7),
        const FlushOutcome.failed(reason: 'server error 500', waiting: 7),
      ),
      (const Unauthorized(), const FlushOutcome.keyRejected()),
      (const NotInitialized(), const FlushOutcome.notRunning()),
    ]) {
      test('$result', () async {
        client.flushResult = result;

        expect(await debug.flush(), outcome);
      });
    }
  });

  test('retryFailed: the SDK\'s count', () async {
    client.fakeDebug.retryFailedAnswer = 3;

    expect(await debug.retryFailed(), 3);
  });
}
