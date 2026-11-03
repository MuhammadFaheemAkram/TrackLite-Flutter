import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/data/analytics/tracklite_analytics_service.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';

import '../helpers/fake_client.dart';

void main() {
  test("the adapter maps the app's words onto the SDK's calls", () {
    final client = FakeClient();
    final analytics = TrackLiteAnalyticsService(client);

    analytics
      ..track('purchase', properties: {'price': 12.5})
      ..track('signed_in')
      ..identify('user_123')
      ..reset();

    expect(client.calls, [
      'track purchase {price: 12.5}',
      'track signed_in {}',
      'setUserId user_123',
      'clearUser',
    ]);
  });

  test('the identity comes from the stats, without repeats', () async {
    final client = FakeClient();
    final seen = <AnalyticsIdentity>[];
    final subscription = TrackLiteAnalyticsService(client)
        .watchIdentity()
        .listen(seen.add);

    client.fakeDebug.stats
      ..add(const TrackLiteStats(anonymousId: 'a'))
      ..add(const TrackLiteStats(anonymousId: 'a', pending: 3))
      ..add(const TrackLiteStats(anonymousId: 'a', userId: 'u'));
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen, const [
      AnalyticsIdentity(anonymousId: 'a'),
      AnalyticsIdentity(anonymousId: 'a', userId: 'u'),
    ]);
  });
}
