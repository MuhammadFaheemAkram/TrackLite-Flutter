import 'package:injectable/injectable.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

/// The adapter: the app's [AnalyticsService] port, implemented with the
/// TrackLite SDK. The only class in the app (besides the DI module) that
/// knows the SDK exists.
///
/// It takes a [TrackLiteClient] rather than calling the static facade, so a
/// test can hand it a fake client and check what it forwards.
@LazySingleton(as: AnalyticsService)
class TrackLiteAnalyticsService implements AnalyticsService {
  const TrackLiteAnalyticsService(this._client);

  final TrackLiteClient _client;

  @override
  void track(String event, {Map<String, Object> properties = const {}}) =>
      _client.track(event, properties: properties);

  @override
  void identify(String userId) => _client.setUserId(userId);

  @override
  void reset() => _client.clearUser();

  @override
  Future<FlushOutcome> flush() async => switch (await _client.flush()) {
    Uploaded(:final events, :final batches) => FlushOutcome.sent(
      events: events,
      requests: batches,
    ),
    NothingToSend() => const FlushOutcome.nothingToSend(),
    Offline() => const FlushOutcome.offline(),
    Failed(:final reason, :final remaining) => FlushOutcome.failed(
      reason: reason,
      waiting: remaining,
    ),
    Unauthorized() => const FlushOutcome.keyRejected(),
    NotInitialized() => const FlushOutcome.notRunning(),
  };

  @override
  Stream<QueueStats> watchQueue() => _client.debug.watchStats().map(
    (stats) => QueueStats(
      anonymousId: stats.anonymousId,
      tracked: stats.tracked,
      pending: stats.pending,
      sending: stats.sending,
      sent: stats.sent,
      failed: stats.failed,
      dropped: stats.dropped,
      rejected: stats.rejected,
      userId: stats.userId,
    ),
  );
}
