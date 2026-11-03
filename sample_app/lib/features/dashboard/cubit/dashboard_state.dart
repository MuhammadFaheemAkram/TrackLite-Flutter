import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    /// `null` until the first snapshot arrives.
    QueueStats? queue,

    /// The device's network and the demo switch; `null` until known.
    NetworkStatus? network,

    /// A flush is running (the button waits for it).
    @Default(false) bool flushing,

    /// The last flush's outcome, shown once; [flushSerial] makes a repeat
    /// show again.
    FlushOutcome? lastFlush,
    @Default(0) int flushSerial,
  }) = _DashboardState;
}
