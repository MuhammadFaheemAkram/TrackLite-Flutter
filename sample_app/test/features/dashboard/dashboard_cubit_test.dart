import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';

import '../../helpers/recording_analytics.dart';

void main() {
  late RecordingAnalytics analytics;

  setUp(() => analytics = RecordingAnalytics());

  test('starts with no queue yet (loading)', () {
    expect(DashboardCubit(analytics).state, const DashboardState());
  });

  blocTest<DashboardCubit, DashboardState>(
    'shows each queue snapshot as it arrives',
    build: () => DashboardCubit(analytics),
    act: (cubit) async {
      cubit.start();
      analytics.emit(const QueueStats(anonymousId: 'a'));
      await Future<void>.delayed(Duration.zero);
      analytics.emit(const QueueStats(anonymousId: 'a', pending: 2));
    },
    expect: () => const [
      DashboardState(queue: QueueStats(anonymousId: 'a')),
      DashboardState(queue: QueueStats(anonymousId: 'a', pending: 2)),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'start twice listens once; close stops listening',
    build: () => DashboardCubit(analytics),
    act: (cubit) async {
      cubit
        ..start()
        ..start();
      analytics.emit(const QueueStats(anonymousId: 'a', tracked: 1));
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      analytics.emit(const QueueStats(anonymousId: 'a', tracked: 2));
    },
    expect: () => const [
      DashboardState(queue: QueueStats(anonymousId: 'a', tracked: 1)),
    ],
  );
}
