import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_service.freezed.dart';

/// Who the analytics events are about.
@freezed
abstract class AnalyticsIdentity with _$AnalyticsIdentity {
  const factory AnalyticsIdentity({
    required String anonymousId,

    /// The signed-in user, if any.
    String? userId,
  }) = _AnalyticsIdentity;
}

/// What the app needs from analytics, in the app's own words.
///
/// The app's code depends on this port, never on the SDK: the Cubits don't
/// import `tracklite`. Only the adapters (in the data layer) do. Swapping
/// the vendor, or using two, then changes one class; and tests pass a fake
/// without starting an SDK. It's the lesson for any third-party SDK,
/// analytics or not. The Dashboard's tools are a port of their own,
/// `AnalyticsDebug`: an everyday screen doesn't need them.
abstract interface class AnalyticsService {
  /// Records that [event] happened, with its [properties] (`String`, `num`
  /// or `bool` values).
  void track(String event, {Map<String, Object> properties = const {}});

  /// Ties the events from now on to [userId] (after signing in).
  void identify(String userId);

  /// Stops tying events to a user (after signing out).
  void reset();

  /// Who the events are about: now, then after every change.
  Stream<AnalyticsIdentity> watchIdentity();
}
