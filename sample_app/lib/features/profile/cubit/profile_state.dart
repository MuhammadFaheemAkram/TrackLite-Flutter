import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    /// `null` until the first snapshot arrives.
    AnalyticsIdentity? identity,
  }) = _ProfileState;
}
