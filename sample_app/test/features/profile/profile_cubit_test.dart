import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_cubit.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_state.dart';

import '../../helpers/recording_analytics.dart';

void main() {
  late RecordingAnalytics analytics;

  setUp(() => analytics = RecordingAnalytics());

  blocTest<ProfileCubit, ProfileState>(
    'shows the identity analytics reports',
    build: () => ProfileCubit(analytics),
    act: (cubit) async {
      cubit.start();
      analytics.emitIdentity(const AnalyticsIdentity(anonymousId: 'a'));
    },
    expect: () => const [
      ProfileState(identity: AnalyticsIdentity(anonymousId: 'a')),
    ],
  );

  test('sign in: the user id first, so signed_in carries it', () {
    ProfileCubit(analytics).signIn('  user_123 ');

    expect(analytics.identities, ['user_123']);
    expect(analytics.events, [const Tracked('signed_in')]);
  });

  test('a blank user id signs nothing in', () {
    ProfileCubit(analytics).signIn('   ');

    expect(analytics.identities, isEmpty);
    expect(analytics.events, isEmpty);
  });

  test('sign out: signed_out while still the user, then forget them', () {
    final order = <String>[];
    final ordered = _OrderedAnalytics(order);

    ProfileCubit(ordered).signOut();

    expect(order, ['track signed_out', 'reset']);
  });

  test('close stops listening', () async {
    final cubit = ProfileCubit(analytics)..start();
    await cubit.close();

    analytics.emitIdentity(const AnalyticsIdentity(anonymousId: 'late'));
    await pumpEventQueue();
    expect(cubit.state.identity, isNull);
  });
}

class _OrderedAnalytics implements AnalyticsService {
  _OrderedAnalytics(this.order);

  final List<String> order;

  @override
  void track(String event, {Map<String, Object> properties = const {}}) =>
      order.add('track $event');

  @override
  void identify(String userId) => order.add('identify $userId');

  @override
  void reset() => order.add('reset');

  @override
  Stream<AnalyticsIdentity> watchIdentity() => const Stream.empty();
}
