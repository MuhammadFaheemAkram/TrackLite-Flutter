/// What the app needs from analytics, in the app's own words.
///
/// The app's code depends on this port, never on the SDK: the Cubits don't
/// import `tracklite`. Only `TrackLiteAnalyticsService` (the adapter, in the
/// data layer) does. Swapping the vendor, or using two, then changes one
/// class; and tests pass a fake without starting an SDK. It's the lesson for
/// any third-party SDK, analytics or not.
abstract interface class AnalyticsService {
  /// Records that [event] happened, with its [properties] (`String`, `num`
  /// or `bool` values).
  void track(String event, {Map<String, Object> properties = const {}});

  /// Ties the events from now on to [userId] (after signing in).
  void identify(String userId);

  /// Stops tying events to a user (after signing out).
  void reset();
}
