import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';

import '../../helpers/recording_analytics.dart';

void main() {
  late FakeAnalyticsDebug debug;
  late RecordingAnalytics analytics;
  late FakeDeviceNetwork network;
  late FakeDemoBackend backend;

  setUp(() {
    debug = FakeAnalyticsDebug();
    analytics = RecordingAnalytics();
    network = FakeDeviceNetwork();
    backend = FakeDemoBackend();
  });

  DashboardCubit build() => DashboardCubit(debug, analytics, network, backend);

  test('starts with nothing known yet (loading)', () {
    expect(build().state, const DashboardState());
  });

  final at = DateTime.utc(2026, 11, 4);
  const server = DemoServerState(
    failures: ServerFailures.none,
    speed: ServerSpeed.fast,
  );

  blocTest<DashboardCubit, DashboardState>(
    'shows each stream as it arrives',
    build: build,
    act: (cubit) async {
      cubit.start();
      debug.emitQueue(const QueueStats(anonymousId: 'a', pending: 2));
      await Future<void>.delayed(Duration.zero);
      network.emit(const NetworkStatus(deviceOnline: true));
      await Future<void>.delayed(Duration.zero);
      backend.emit(server);
      await Future<void>.delayed(Duration.zero);
      debug.emitRecent([
        RecentEvent(
          id: 'e',
          name: 'tap',
          trackedAt: at,
          state: EventState.pending,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);
      debug.emitUploads([
        UploadRun(
          trigger: 'manual',
          finishedAt: at,
          outcome: UploadOutcome.uploaded,
        ),
      ]);
    },
    skip: 4,
    expect: () => [
      DashboardState(
        queue: const QueueStats(anonymousId: 'a', pending: 2),
        network: const NetworkStatus(deviceOnline: true),
        server: server,
        recentEvents: [
          RecentEvent(
            id: 'e',
            name: 'tap',
            trackedAt: at,
            state: EventState.pending,
          ),
        ],
        uploads: [
          UploadRun(
            trigger: 'manual',
            finishedAt: at,
            outcome: UploadOutcome.uploaded,
          ),
        ],
      ),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'start twice listens once; close stops listening',
    build: build,
    act: (cubit) async {
      cubit
        ..start()
        ..start();
      debug.emitQueue(const QueueStats(anonymousId: 'a', tracked: 1));
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      debug.emitQueue(const QueueStats(anonymousId: 'a', tracked: 2));
    },
    expect: () => const [
      DashboardState(queue: QueueStats(anonymousId: 'a', tracked: 1)),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'flush: sending, then the outcome, counted so it shows once',
    build: build,
    setUp: () =>
        debug.flushOutcome = const FlushOutcome.sent(events: 3, requests: 1),
    act: (cubit) => cubit.flush(),
    expect: () => const [
      DashboardState(flushing: true),
      DashboardState(
        effect: DashboardEffect.flushed(
          FlushOutcome.sent(events: 3, requests: 1),
        ),
        effectSerial: 1,
      ),
    ],
  );

  test('a second flush while one runs is ignored', () async {
    debug.flushGate = Completer<void>();
    final cubit = build();
    addTearDown(cubit.close);

    final first = cubit.flush();
    await cubit.flush();
    debug.flushGate!.complete();
    await first;

    expect(debug.flushes, 1);
    expect(cubit.state.effectSerial, 1);
  });

  test('closed while flushing: no state after close', () async {
    debug.flushGate = Completer<void>();
    final cubit = build();

    final flushing = cubit.flush();
    await cubit.close();
    debug.flushGate!.complete();

    await expectLater(flushing, completes);
  });

  blocTest<DashboardCubit, DashboardState>(
    'retry failed: asks the port, and says how many',
    build: build,
    setUp: () => debug.retryFailedAnswer = 4,
    act: (cubit) => cubit.retryFailed(),
    expect: () => const [
      DashboardState(effect: DashboardEffect.retried(4), effectSerial: 1),
    ],
    verify: (_) => expect(debug.retries, 1),
  );

  blocTest<DashboardCubit, DashboardState>(
    'track 100 events: 100 demo events, numbered, then says so',
    build: build,
    act: (cubit) => cubit.trackBurst(),
    expect: () => const [
      DashboardState(
        effect: DashboardEffect.tracked(DashboardCubit.burst),
        effectSerial: 1,
      ),
    ],
    verify: (_) {
      expect(analytics.events, hasLength(100));
      expect(analytics.events.first, const Tracked('demo_burst', {'n': 1}));
      expect(analytics.events.last, const Tracked('demo_burst', {'n': 100}));
    },
  );

  test('the demo controls go to their ports', () {
    build()
      ..simulateOffline(true)
      ..setServerFailures(ServerFailures.half)
      ..setServerSpeed(ServerSpeed.slow);

    expect(network.switched, [true]);
    expect(backend.set, [ServerFailures.half, ServerSpeed.slow]);
  });
}
