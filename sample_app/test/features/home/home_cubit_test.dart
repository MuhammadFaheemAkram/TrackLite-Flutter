import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/features/home/cubit/home_cubit.dart';
import 'package:tracklite_sample/features/home/cubit/home_state.dart';

import '../../helpers/recording_analytics.dart';

void main() {
  late RecordingAnalytics analytics;

  setUp(() => analytics = RecordingAnalytics());

  test('starts with nothing tapped', () {
    expect(HomeCubit(analytics).state, const HomeState());
  });

  blocTest<HomeCubit, HomeState>(
    'each tap tracks button_clicked with the button, and counts',
    build: () => HomeCubit(analytics),
    act: (cubit) => cubit
      ..tapped(HomeButton.share)
      ..tapped(HomeButton.rate),
    expect: () => const [
      HomeState(lastTapped: HomeButton.share, taps: 1),
      HomeState(lastTapped: HomeButton.rate, taps: 2),
    ],
    verify: (_) => expect(analytics.events, [
      const Tracked('button_clicked', {'button': 'share'}),
      const Tracked('button_clicked', {'button': 'rate'}),
    ]),
  );
}
