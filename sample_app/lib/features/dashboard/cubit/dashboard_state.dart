import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';

part 'dashboard_state.freezed.dart';

/// Something the Dashboard says once, in a SnackBar.
@freezed
sealed class DashboardEffect with _$DashboardEffect {
  const factory DashboardEffect.flushed(FlushOutcome outcome) = Flushed;

  /// [count] failed events went back in the queue.
  const factory DashboardEffect.retried(int count) = Retried;

  /// [count] demo events were tracked at once.
  const factory DashboardEffect.tracked(int count) = TrackedBurst;
}

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    /// `null` until the first snapshot arrives.
    QueueStats? queue,

    /// The device's network and the demo switch; `null` until known.
    NetworkStatus? network,

    /// The demo server's settings and stats; `null` until known.
    DemoServerState? server,

    /// The newest events, newest first.
    @Default(<RecentEvent>[]) List<RecentEvent> recentEvents,

    /// The newest upload runs, newest first.
    @Default(<UploadRun>[]) List<UploadRun> uploads,

    /// A flush is running (the button waits for it).
    @Default(false) bool flushing,

    /// The last thing to say, shown once; [effectSerial] makes a repeat
    /// show again.
    DashboardEffect? effect,
    @Default(0) int effectSerial,
  }) = _DashboardState;
}
