import 'package:injectable/injectable.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

/// The Dashboard's [AnalyticsDebug] port, implemented with the SDK's debug
/// tools: each of the SDK's models mapped onto the app's own.
@LazySingleton(as: AnalyticsDebug)
class TrackLiteAnalyticsDebug implements AnalyticsDebug {
  const TrackLiteAnalyticsDebug(this._client);

  final TrackLiteClient _client;

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
      nextRetryAt: stats.nextRetryAt,
      lastUpload: switch (stats.lastUpload) {
        final record? => _runOf(record),
        null => null,
      },
      uploading: stats.isUploading,
    ),
  );

  @override
  Stream<List<RecentEvent>> watchRecentEvents() =>
      _client.debug.watchRecentEvents().map(
        (events) => [
          for (final event in events)
            RecentEvent(
              id: event.id,
              name: event.name,
              trackedAt: event.timestamp,
              state: switch (event.status) {
                EventStatus.pending => EventState.pending,
                EventStatus.sending => EventState.sending,
                EventStatus.sent => EventState.sent,
                EventStatus.failed => EventState.failed,
              },
              summary: [
                for (final MapEntry(:key, :value) in event.properties.entries)
                  '$key: $value',
              ].join(', '),
              attempts: event.attempts,
              retryAt: event.nextAttemptAt,
              lastError: event.lastError,
            ),
        ],
      );

  @override
  Stream<List<UploadRun>> watchUploads() => _client.debug.watchUploads().map(
    (records) => [for (final record in records) _runOf(record)],
  );

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
  Future<int> retryFailed() => _client.debug.retryFailed();

  static UploadRun _runOf(UploadRecord record) => UploadRun(
    trigger: record.trigger,
    finishedAt: record.finishedAt,
    outcome: switch (record.outcome) {
      'uploaded' => UploadOutcome.uploaded,
      'offline' => UploadOutcome.offline,
      'failed' => UploadOutcome.failed,
      'unauthorized' => UploadOutcome.keyRejected,
      _ => UploadOutcome.nothing,
    },
    events: record.events,
    error: record.error,
  );
}
