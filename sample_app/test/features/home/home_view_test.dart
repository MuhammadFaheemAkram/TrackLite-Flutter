import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracklite_sample/features/home/cubit/home_cubit.dart';
import 'package:tracklite_sample/features/home/cubit/home_state.dart';
import 'package:tracklite_sample/features/home/home_page.dart';

import '../../helpers/pump_app.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  late _MockHomeCubit cubit;

  setUp(() => cubit = _MockHomeCubit());

  Future<void> pump(WidgetTester tester, HomeState state) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpThemed(
      BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
    );
  }

  testWidgets('each button says what it sends', (tester) async {
    await pump(tester, const HomeState());

    for (final button in HomeButton.values) {
      expect(find.text(button.label), findsOneWidget);
      expect(
        find.text('Sends button_clicked, button: ${button.id}'),
        findsOneWidget,
      );
    }
    expect(find.textContaining('Tracked'), findsNothing);
  });

  testWidgets('a tap goes to the Cubit', (tester) async {
    await pump(tester, const HomeState());

    await tester.tap(find.text('Rate the app'));

    verify(() => cubit.tapped(HomeButton.rate)).called(1);
  });

  testWidgets('after a tap, says what was tracked', (tester) async {
    await pump(tester, const HomeState(lastTapped: HomeButton.share, taps: 3));

    expect(find.text('Tracked button_clicked (share). 3 so far.'), findsOne);
  });
}
