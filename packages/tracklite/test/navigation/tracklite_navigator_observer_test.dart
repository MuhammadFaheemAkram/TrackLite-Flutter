import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/tracklite.dart';

class _RecordingClient implements TrackLiteClient {
  final screens = <String>[];

  @override
  void track(String name, {Map<String, Object> properties = const {}}) {
    expect(name, 'screen_opened');
    expect(properties.keys, ['screen']);
    screens.add(properties['screen']! as String);
  }

  @override
  void setUserId(String userId) {}

  @override
  void clearUser() {}

  @override
  Future<FlushResult> flush() async => const NothingToSend();

  @override
  Future<void> shutdown() async {}

  @override
  TrackLiteDebug get debug => throw UnimplementedError();
}

void main() {
  late _RecordingClient client;
  late GlobalKey<NavigatorState> navigator;

  setUp(() => client = _RecordingClient());

  Future<void> pumpNavigator(
    WidgetTester tester, {
    TrackLiteNavigatorObserver? observer,
  }) {
    navigator = GlobalKey<NavigatorState>();
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Navigator(
          key: navigator,
          observers: [observer ?? TrackLiteNavigatorObserver(client: client)],
          onGenerateRoute: (settings) => _page('home'),
        ),
      ),
    );
  }

  testWidgets('the first route is skipped; a push is a screen', (tester) async {
    await pumpNavigator(tester);
    expect(client.screens, isEmpty);

    navigator.currentState!.push(_page('product'));
    await tester.pumpAndSettle();

    expect(client.screens, ['product']);
  });

  testWidgets('a pop shows the screen underneath again', (tester) async {
    await pumpNavigator(tester);
    navigator.currentState!.push(_page('product'));
    await tester.pumpAndSettle();

    navigator.currentState!.pop();
    await tester.pumpAndSettle();

    expect(client.screens, ['product', 'home']);
  });

  testWidgets('a replacement is a screen', (tester) async {
    await pumpNavigator(tester);
    navigator.currentState!.push(_page('a'));
    await tester.pumpAndSettle();

    navigator.currentState!.pushReplacement(_page('b'));
    await tester.pumpAndSettle();

    expect(client.screens, ['a', 'b']);
  });

  testWidgets('unnamed routes and popups are not screens', (tester) async {
    await pumpNavigator(tester);

    navigator.currentState!.push(_page(null));
    await tester.pumpAndSettle();
    navigator.currentState!.push(_page(''));
    await tester.pumpAndSettle();
    navigator.currentState!.push(
      RawDialogRoute<void>(
        settings: const RouteSettings(name: 'dialog'),
        pageBuilder: (_, _, _) => const SizedBox(),
      ),
    );
    await tester.pumpAndSettle();

    expect(client.screens, isEmpty);
  });

  testWidgets("a name of the host's choice; null skips", (tester) async {
    await pumpNavigator(
      tester,
      observer: TrackLiteNavigatorObserver(
        client: client,
        screenName: (route) => route.settings.name == 'secret'
            ? null
            : 'Screen: ${route.settings.name}',
      ),
    );

    navigator.currentState!.push(_page('secret'));
    await tester.pumpAndSettle();
    navigator.currentState!.push(_page('product'));
    await tester.pumpAndSettle();

    expect(client.screens, ['Screen: product']);
  });
}

PageRoute<void> _page(String? name) => PageRouteBuilder<void>(
  settings: RouteSettings(name: name),
  pageBuilder: (_, _, _) => const SizedBox(),
);
