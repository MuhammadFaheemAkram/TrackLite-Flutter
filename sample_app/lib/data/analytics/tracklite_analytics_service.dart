import 'package:injectable/injectable.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';

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
}
