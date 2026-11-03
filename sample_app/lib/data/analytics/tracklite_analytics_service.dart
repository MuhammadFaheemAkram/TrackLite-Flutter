import 'package:injectable/injectable.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';

/// The adapter: the app's [AnalyticsService] port, implemented with the
/// TrackLite SDK.
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

  @override
  Stream<AnalyticsIdentity> watchIdentity() => _client.debug
      .watchStats()
      .map(
        (stats) => AnalyticsIdentity(
          anonymousId: stats.anonymousId,
          userId: stats.userId,
        ),
      )
      .distinct();
}
