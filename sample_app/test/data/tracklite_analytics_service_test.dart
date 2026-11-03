import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/data/analytics/tracklite_analytics_service.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

/// A host-side fake of the SDK's client: possible because the SDK exposes an
/// interface, not only static calls.
class _FakeClient implements TrackLiteClient {
  final calls = <String>[];
  FlushResult flushResult = const NothingToSend();

  @override
  void track(String name, {Map<String, Object> properties = const {}}) =>
      calls.add('track $name $properties');

  @override
  void setUserId(String userId) => calls.add('setUserId $userId');

  @override
  void clearUser() => calls.add('clearUser');

  @override
  Future<FlushResult> flush() async => flushResult;

  @override
  Future<void> shutdown() async {}

  @override
  TrackLiteDebug get debug => _FakeDebug();
}

class _FakeDebug implements TrackLiteDebug {
  @override
  Stream<TrackLiteStats> watchStats() => Stream.value(
    const TrackLiteStats(
      anonymousId: 'anon',
      userId: 'user_123',
      tracked: 9,
      pending: 2,
      sending: 3,
      sent: 1,
      failed: 1,
      dropped: 4,
      rejected: 5,
    ),
  );
}

void main() {
  test("the adapter maps the app's words onto the SDK's calls", () {
    final client = _FakeClient();
    final analytics = TrackLiteAnalyticsService(client);

    analytics
      ..track('purchase', properties: {'price': 12.5})
      ..track('signed_in')
      ..identify('user_123')
      ..reset();

    expect(client.calls, [
      'track purchase {price: 12.5}',
      'track signed_in {}',
      'setUserId user_123',
      'clearUser',
    ]);
  });

  test("the queue comes from the SDK's debug stats, field by field", () async {
    final analytics = TrackLiteAnalyticsService(_FakeClient());

    expect(
      await analytics.watchQueue().first,
      const QueueStats(
        anonymousId: 'anon',
        userId: 'user_123',
        tracked: 9,
        pending: 2,
        sending: 3,
        sent: 1,
        failed: 1,
        dropped: 4,
        rejected: 5,
      ),
    );
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
        final client = _FakeClient()..flushResult = result;

        expect(await TrackLiteAnalyticsService(client).flush(), outcome);
      });
    }
  });
}
