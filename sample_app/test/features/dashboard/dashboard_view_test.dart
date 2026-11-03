import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/flush_outcome.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_page.dart';

import '../../helpers/pump_app.dart';

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

void main() {
  late _MockDashboardCubit cubit;

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
    tester.usePhoneSurface();
    return tester.pumpThemed(
      BlocProvider<DashboardCubit>.value(
        value: cubit,
        child: const DashboardView(),
      ),
    );
  }

  testWidgets('before the first snapshot: loading', (tester) async {
    await pump(tester, const DashboardState());

    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.text('Reading the queue…'), findsOneWidget);
  });

  testWidgets('each count, with its word, read as one phrase', (tester) async {
    await pump(
      tester,
      const DashboardState(
        queue: QueueStats(
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

  testWidgets('the identity: Anonymous without a user id', (tester) async {
    await pump(
      tester,
      const DashboardState(queue: QueueStats(anonymousId: 'anon-1')),
    );

    expect(find.text('Anonymous'), findsOneWidget);
    expect(find.text('anon-1'), findsOneWidget);
  });

  testWidgets('the identity: the user id when signed in', (tester) async {
    await pump(
      tester,
      const DashboardState(
        queue: QueueStats(anonymousId: 'anon-1', userId: 'user_123'),
      ),
    );

    expect(find.text('user_123'), findsOneWidget);
    expect(find.text('Anonymous'), findsNothing);
  });

  const ready = DashboardState(queue: QueueStats(anonymousId: 'a', pending: 3));

  testWidgets('Flush now goes to the Cubit', (tester) async {
    when(() => cubit.flush()).thenAnswer((_) async {});
    await pump(tester, ready);

    await tester.tap(find.text('Flush now'));

    verify(() => cubit.flush()).called(1);
  });

  testWidgets('while flushing: "Sending…", and the button waits', (
    tester,
  ) async {
    await pump(tester, ready.copyWith(flushing: true));

    expect(find.text('Sending…'), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Sending…'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a finished flush shows its outcome in a SnackBar', (
    tester,
  ) async {
    final done = ready.copyWith(
      lastFlush: const FlushOutcome.sent(events: 3, requests: 1),
      flushSerial: 1,
    );
    await pump(tester, ready, states: Stream.value(done));
    await tester.pump();

    expect(
      find.widgetWithText(SnackBar, 'Sent 3 events in 1 request.'),
      findsOneWidget,
    );
  });

  group('the network', () {
    for (final (status, label) in [
      (const NetworkStatus(deviceOnline: true), 'Online'),
      (
        const NetworkStatus(deviceOnline: true, simulatingOffline: true),
        'Offline (simulated)',
      ),
      (const NetworkStatus(deviceOnline: false), 'Offline: no connection'),
    ]) {
      testWidgets(label, (tester) async {
        await pump(tester, ready.copyWith(network: status));

        expect(find.text(label), findsOneWidget);
        final toggle = tester.widget<SwitchListTile>(
          find.byType(SwitchListTile),
        );
        expect(toggle.value, status.simulatingOffline);
      });
    }

    testWidgets('the Device offline switch goes to the Cubit', (tester) async {
      await pump(
        tester,
        ready.copyWith(network: const NetworkStatus(deviceOnline: true)),
      );

      await tester.tap(find.text('Device offline'));

      verify(() => cubit.simulateOffline(true)).called(1);
    });

    testWidgets('before the network is known: no section yet', (tester) async {
      await pump(tester, ready);

      expect(find.text('Device offline'), findsNothing);
    });
  });
}
