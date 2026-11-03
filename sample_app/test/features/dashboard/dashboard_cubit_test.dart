import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
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

  blocTest<DashboardCubit, DashboardState>(
    'flush: sending, then the outcome, counted so it shows once',
    build: () => DashboardCubit(analytics),
    setUp: () => analytics.flushOutcome = const FlushOutcome.sent(
      events: 3,
      requests: 1,
    ),
    act: (cubit) => cubit.flush(),
    expect: () => const [
      DashboardState(flushing: true),
      DashboardState(
        lastFlush: FlushOutcome.sent(events: 3, requests: 1),
        flushSerial: 1,
      ),
    ],
  );

  test('a second flush while one runs is ignored', () async {
    analytics.flushGate = Completer<void>();
    final cubit = DashboardCubit(analytics);
    addTearDown(cubit.close);

    final first = cubit.flush();
    await cubit.flush();
    analytics.flushGate!.complete();
    await first;

    expect(analytics.flushes, 1);
    expect(cubit.state.flushSerial, 1);
  });

  test('closed while flushing: no state after close', () async {
    analytics.flushGate = Completer<void>();
    final cubit = DashboardCubit(analytics);

    final flushing = cubit.flush();
    await cubit.close();
    analytics.flushGate!.complete();

    await expectLater(flushing, completes);
  });
}
