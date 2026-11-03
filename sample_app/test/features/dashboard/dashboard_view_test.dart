import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_page.dart';

import '../../helpers/pump_app.dart';

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

void main() {
  late _MockDashboardCubit cubit;
  final at = DateTime.utc(2026, 11, 4, 9, 41, 5);

  setUp(() => cubit = _MockDashboardCubit());

  Future<void> pump(
    WidgetTester tester,
    DashboardState state, {
    Stream<DashboardState>? states,
  }) {
    whenListen(
      cubit,
      states ?? const Stream<DashboardState>.empty(),
      initialState: state,
    );
    // Phone width, tall enough for every section: a lazy list builds only
    // the rows that show.
    tester.view
      ..physicalSize = const Size(390 * 3, 5000 * 3)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    return tester.pumpThemed(
      BlocProvider<DashboardCubit>.value(
        value: cubit,
        child: const DashboardView(),
      ),
    );
  }

  const ready = DashboardState(
    queue: QueueStats(anonymousId: 'anon-1', pending: 3),
    network: NetworkStatus(deviceOnline: true),
    server: DemoServerState(
      failures: ServerFailures.some,
      speed: ServerSpeed.normal,
    ),
  );

  testWidgets('before the first snapshot: loading', (tester) async {
    await pump(tester, const DashboardState());

    expect(find.byType(LoadingView), findsOneWidget);
  });

  group('the queue', () {
    testWidgets('each count, with its word, read as one phrase', (
      tester,
    ) async {
      await pump(
        tester,
        ready.copyWith(
          queue: const QueueStats(
            anonymousId: 'anon-1',
            tracked: 12,
            pending: 7,
            sending: 1,
            sent: 3,
            failed: 2,
            dropped: 4,
            rejected: 5,
          ),
        ),
      );

      for (final (label, value) in [
        ('Pending', '7'),
        ('Sending', '1'),
        ('Sent (ever)', '3'),
        ('Failed', '2'),
        ('Tracked', '12'),
        ('Dropped (queue full)', '4'),
        ('Rejected (invalid)', '5'),
      ]) {
        expect(find.bySemanticsLabel('$label: $value'), findsOneWidget);
      }
    });

    testWidgets('an upload running shows a progress line', (tester) async {
      await pump(
        tester,
        ready.copyWith(
          queue: const QueueStats(anonymousId: 'a', uploading: true),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('the actions go to the Cubit', (tester) async {
      when(() => cubit.flush()).thenAnswer((_) async {});
      when(() => cubit.retryFailed()).thenAnswer((_) async {});
      await pump(
        tester,
        ready.copyWith(queue: const QueueStats(anonymousId: 'a', failed: 2)),
      );

      await tester.tap(find.text('Flush now'));
      await tester.tap(find.text('Retry failed'));
      await tester.tap(find.text('Track 100 events'));

      verify(() => cubit.flush()).called(1);
      verify(() => cubit.retryFailed()).called(1);
      verify(() => cubit.trackBurst()).called(1);
    });

    testWidgets('Retry failed waits for a failed event', (tester) async {
      await pump(tester, ready);

      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Retry failed'),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('while flushing: "Sending…", and the button waits', (
      tester,
    ) async {
      await pump(tester, ready.copyWith(flushing: true));

      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Sending…'),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.onPressed, isNull);
    });
  });

  testWidgets('an effect shows once, in a SnackBar', (tester) async {
    await pump(
      tester,
      ready,
      states: Stream.value(
        ready.copyWith(
          effect: const DashboardEffect.flushed(
            FlushOutcome.sent(events: 3, requests: 1),
          ),
          effectSerial: 1,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.widgetWithText(SnackBar, 'Sent 3 events in 1 request.'),
      findsOneWidget,
    );
  });

  group('uploads', () {
    testWidgets('none yet, no retry waiting', (tester) async {
      await pump(tester, ready);

      expect(find.text('None yet'), findsOneWidget);
      expect(find.text('No event is waiting for a retry'), findsOneWidget);
    });

    testWidgets('the last upload and the next retry, in words', (tester) async {
      await pump(
        tester,
        ready.copyWith(
          queue: QueueStats(
            anonymousId: 'a',
            nextRetryAt: at,
            lastUpload: UploadRun(
              trigger: 'threshold',
              finishedAt: at,
              outcome: UploadOutcome.uploaded,
              events: 20,
            ),
          ),
        ),
      );

      expect(
        find.textContaining('Full batch · Uploaded, 20 events'),
        findsOneWidget,
      );
      expect(find.textContaining('(backoff after a server error)'), findsOne);
    });

    for (final (status, label) in [
      (const NetworkStatus(deviceOnline: true), 'Online'),
      (
        const NetworkStatus(deviceOnline: true, simulatingOffline: true),
        'Offline (simulated)',
      ),
      (const NetworkStatus(deviceOnline: false), 'Offline: no connection'),
    ]) {
      testWidgets('the network: $label', (tester) async {
        await pump(tester, ready.copyWith(network: status));

        expect(find.text(label), findsOneWidget);
        final toggle = tester.widget<SwitchListTile>(
          find.byType(SwitchListTile),
        );
        expect(toggle.value, status.simulatingOffline);
      });
    }

    testWidgets('the Device offline switch goes to the Cubit', (tester) async {
      await pump(tester, ready);

      await tester.tap(find.text('Device offline'));

      verify(() => cubit.simulateOffline(true)).called(1);
    });
  });

  group('the demo server', () {
    testWidgets('its settings and what it has seen', (tester) async {
      await pump(
        tester,
        ready.copyWith(
          server: const DemoServerState(
            failures: ServerFailures.half,
            speed: ServerSpeed.slow,
            requests: 8,
            accepted: 120,
            duplicates: 20,
            serverFailures: 3,
          ),
        ),
      );

      for (final (label, value) in [
        ('Requests received', '8'),
        ('Events stored', '120'),
        ('Duplicates dropped', '20'),
        ('Requests failed', '3'),
      ]) {
        expect(find.bySemanticsLabel('$label: $value'), findsOneWidget);
      }
      final failures = tester.widget<SegmentedButton<ServerFailures>>(
        find.byType(SegmentedButton<ServerFailures>),
      );
      expect(failures.selected, {ServerFailures.half});
    });

    testWidgets('the knobs go to the Cubit', (tester) async {
      await pump(tester, ready);

      await tester.tap(find.text('100 %'));
      await tester.tap(find.text('Slow'));

      verify(() => cubit.setServerFailures(ServerFailures.all)).called(1);
      verify(() => cubit.setServerSpeed(ServerSpeed.slow)).called(1);
    });
  });

  group('identity', () {
    testWidgets('Anonymous without a user id', (tester) async {
      await pump(tester, ready);

      expect(find.text('Anonymous'), findsOneWidget);
      expect(find.text('anon-1'), findsOneWidget);
    });

    testWidgets('the user id when signed in', (tester) async {
      await pump(
        tester,
        ready.copyWith(
          queue: const QueueStats(anonymousId: 'anon-1', userId: 'user_123'),
        ),
      );

      expect(find.text('user_123'), findsOneWidget);
    });
  });

  group('the lists', () {
    testWidgets('empty: says so', (tester) async {
      await pump(tester, ready);

      expect(find.text('Nothing tracked yet'), findsOneWidget);
      expect(find.text('No upload yet'), findsOneWidget);
    });

    testWidgets('an event: its state as a word, its errors and retry', (
      tester,
    ) async {
      await pump(
        tester,
        ready.copyWith(
          recentEvents: [
            RecentEvent(
              id: 'e1',
              name: 'purchase',
              trackedAt: at,
              state: EventState.pending,
              attempts: 2,
              retryAt: at,
              lastError: 'server error 500',
            ),
            RecentEvent(
              id: 'e2',
              name: 'tap',
              trackedAt: at,
              state: EventState.failed,
            ),
          ],
        ),
      );

      expect(find.text('purchase'), findsOneWidget);
      expect(find.textContaining('2 server errors · retry at'), findsOne);
      expect(find.textContaining('server error 500'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.text('Pending'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.text('Failed'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('an upload run: why, what came of it, and the error', (
      tester,
    ) async {
      await pump(
        tester,
        ready.copyWith(
          uploads: [
            UploadRun(
              trigger: 'reconnect',
              finishedAt: at,
              outcome: UploadOutcome.failed,
              error: 'server error 503',
            ),
          ],
        ),
      );

      expect(find.text('Reconnected · Failed'), findsOneWidget);
      expect(find.textContaining('server error 503'), findsOneWidget);
    });
  });
}
