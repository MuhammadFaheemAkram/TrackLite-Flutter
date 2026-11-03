import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/app/tracklite_sample_app.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';

import 'pump_app.dart';

/// Starts the whole app as `main()` does (the SDK, then the DI graph),
/// optionally on a deep link. Pass [analytics] to record the events the
/// screens send instead of handing them to the SDK. Pair it with
/// `tearDown(tearDownSample)`.
Future<void> pumpSample(
  WidgetTester tester, {
  String? initialLocation,
  AnalyticsService? analytics,
}) async {
  await startSdk();
  configureDependencies();
  if (analytics != null) {
    getIt
      ..unregister<AnalyticsService>()
      ..registerSingleton<AnalyticsService>(analytics);
  }
  tester.usePhoneSurface();
  await tester.pumpWidget(TrackLiteSampleApp(initialLocation: initialLocation));
  await tester.pumpAndSettle();
}

/// The fake server the app's SDK talks to in tests: instant and reliable,
/// unless a test turns its knobs.
late FakeAnalyticsServer testServer;

/// Starts the real SDK as `main()` does, on a fresh in-memory database (a
/// widget test has no file system for it), with [testServer] as its
/// backend.
Future<void> startSdk() {
  TrackLiteTesting.useInMemoryDatabase();
  testServer = FakeAnalyticsServer(latency: Duration.zero, failureRate: 0);
  return TrackLite.initialize(
    TrackLiteConfig(apiKey: 'demo_key', transport: testServer),
  );
}

/// Undoes [pumpSample]: a fresh graph and a stopped SDK for the next test.
Future<void> tearDownSample() async {
  await getIt.reset();
  await TrackLite.shutdown();
}

/// The bottom bar's destination labelled [label] (a tab).
Finder destination(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// The app bar showing [title]: which screen is on top.
Finder appBarTitled(String title) => find.widgetWithText(AppBar, title);

extension AppHarness on WidgetTester {
  /// The index of the selected tab.
  int get selectedTab =>
      widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
