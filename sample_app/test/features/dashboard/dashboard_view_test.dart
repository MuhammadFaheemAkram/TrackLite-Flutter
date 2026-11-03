import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_page.dart';

import '../../helpers/pump_app.dart';

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

void main() {
  late _MockDashboardCubit cubit;

  setUp(() => cubit = _MockDashboardCubit());

  Future<void> pump(WidgetTester tester, DashboardState state) {
    when(() => cubit.state).thenReturn(state);
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
      ('Sent', '3'),
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
}
