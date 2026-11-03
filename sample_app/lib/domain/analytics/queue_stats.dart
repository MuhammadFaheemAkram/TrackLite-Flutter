import 'package:freezed_annotation/freezed_annotation.dart';

part 'queue_stats.freezed.dart';

/// What the analytics queue holds, in the app's own model: the Dashboard
/// shows it without knowing which SDK keeps the queue.
@freezed
abstract class QueueStats with _$QueueStats {
  const factory QueueStats({
    required String anonymousId,
    @Default(0) int tracked,
    @Default(0) int pending,
    @Default(0) int sending,
    @Default(0) int sent,
    @Default(0) int failed,
    @Default(0) int dropped,
    @Default(0) int rejected,
    String? userId,
  }) = _QueueStats;
}
