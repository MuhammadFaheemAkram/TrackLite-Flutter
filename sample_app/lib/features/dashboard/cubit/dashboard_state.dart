import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    /// `null` until the first snapshot arrives.
    QueueStats? queue,
  }) = _DashboardState;
}
