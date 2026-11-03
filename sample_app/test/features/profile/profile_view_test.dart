import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_cubit.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_state.dart';
import 'package:tracklite_sample/features/profile/profile_page.dart';

import '../../helpers/pump_app.dart';

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  late _MockProfileCubit cubit;

  setUp(() => cubit = _MockProfileCubit());

  Future<void> pump(WidgetTester tester, ProfileState state) {
    when(() => cubit.state).thenReturn(state);
    tester.usePhoneSurface();
    return tester.pumpThemed(
      BlocProvider<ProfileCubit>.value(
        value: cubit,
        child: const ProfileView(),
      ),
    );
  }

  testWidgets('before the identity is known: loading', (tester) async {
    await pump(tester, const ProfileState());

    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('signed out: the form, with Sign in off until a user id', (
    tester,
  ) async {
    await pump(
      tester,
      const ProfileState(identity: AnalyticsIdentity(anonymousId: 'anon-1')),
    );

    expect(find.text('Signed out'), findsOneWidget);
    expect(find.text('anon-1'), findsOneWidget);
    FilledButton signIn() => tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Sign in'),
        matching: find.bySubtype<FilledButton>(),
      ),
    );
    expect(signIn().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'user_123');
    await tester.pump();
    expect(signIn().onPressed, isNotNull);

    await tester.tap(find.text('Sign in'));
    verify(() => cubit.signIn('user_123')).called(1);
  });

  testWidgets('the keyboard\'s Done signs in too', (tester) async {
    await pump(
      tester,
      const ProfileState(identity: AnalyticsIdentity(anonymousId: 'a')),
    );

    await tester.enterText(find.byType(TextField), 'user_9');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    verify(() => cubit.signIn('user_9')).called(1);
  });

  testWidgets('signed in: who, and Sign out', (tester) async {
    await pump(
      tester,
      const ProfileState(
        identity: AnalyticsIdentity(anonymousId: 'anon-1', userId: 'user_123'),
      ),
    );

    expect(find.text('user_123'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Sign out'));
    verify(() => cubit.signOut()).called(1);
  });
}
