import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

part 'analytics_debug.freezed.dart';

/// Where an event is, in the app's words.
enum EventState { pending, sending, sent, failed }

/// One event the queue holds, for the Dashboard's list.
@freezed
abstract class RecentEvent with _$RecentEvent {
  const factory RecentEvent({
    required String id,
    required String name,
    required DateTime trackedAt,
    required EventState state,

    /// The properties in short: `screen: product, price: 12.5`.
    @Default('') String summary,
    @Default(0) int attempts,
    DateTime? retryAt,
    String? lastError,
  }) = _RecentEvent;
}

/// How an upload run ended.
enum UploadOutcome { uploaded, nothing, offline, failed, keyRejected }

/// One upload run, for the Dashboard's log.
@freezed
abstract class UploadRun with _$UploadRun {
  const factory UploadRun({
    /// What started it, as the SDK names it (`manual`, `interval`, …).
    required String trigger,
    required DateTime finishedAt,
    required UploadOutcome outcome,
    @Default(0) int events,
    String? error,
  }) = _UploadRun;
}

/// The analytics tools the Dashboard needs: the queue, the log, sending now
/// and retrying. A port of its own, so the everyday screens don't see it.
abstract interface class AnalyticsDebug {
  /// What the queue holds now, then after every change.
  Stream<QueueStats> watchQueue();

  /// The newest events, any state: now, then after every change.
  Stream<List<RecentEvent>> watchRecentEvents();

  /// The newest upload runs: now, then after every run.
  Stream<List<UploadRun>> watchUploads();

  /// Sends what is waiting now, and says what happened.
  Future<FlushOutcome> flush();

  /// Puts the events given up on back in the queue; says how many.
  Future<int> retryFailed();
}
