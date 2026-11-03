import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// The real SDK, on an in-memory database: what a tap tracks is stored, and
// the Dashboard shows it from the SDK's own stream.
void main() {
  tearDown(tearDownSample);

  // Phone width, but tall enough for the whole Dashboard: a lazy list
  // builds only the rows that show.
  Future<void> pumpTall(WidgetTester tester, {String? initialLocation}) async {
    await pumpSample(tester, initialLocation: initialLocation);
    tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
    await tester.pump();
  }

  Future<void> settleStorage(WidgetTester tester) async {
    // The SDK writes on its own schedule (a microtask, then the database);
    // let real time run so the write and the stream's update both land.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('a fresh install: an empty queue and an anonymous id', (
    tester,
  ) async {
    await pumpTall(tester, initialLocation: '/dashboard');
    await settleStorage(tester);

    expect(find.bySemanticsLabel('Pending: 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Tracked: 0'), findsOneWidget);
    expect(find.text('Anonymous'), findsOneWidget);
  });

  testWidgets('Buy, then the Dashboard: the purchase is stored, pending', (
    tester,
  ) async {
    await pumpTall(tester, initialLocation: '/shop/grinder');

    await tester.tapAndSettle(find.text('Buy'));
    await settleStorage(tester);
    await tester.tapAndSettle(destination('Dashboard'));
    await settleStorage(tester);

    expect(find.bySemanticsLabel('Pending: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Tracked: 1'), findsOneWidget);
  });

  testWidgets('the Dashboard updates while it is open', (tester) async {
    await pumpTall(tester, initialLocation: '/dashboard');
    await settleStorage(tester);

    await tester.tapAndSettle(destination('Home'));
    await tester.tapAndSettle(find.text('Share'));
    await tester.tapAndSettle(find.text('Rate the app'));
    await settleStorage(tester);
    await tester.tapAndSettle(destination('Dashboard'));
    await settleStorage(tester);

    expect(find.bySemanticsLabel('Pending: 2'), findsOneWidget);
  });

  testWidgets('Flush now sends the queue to the server: Sent 1, Pending 0', (
    tester,
  ) async {
    await pumpTall(tester, initialLocation: '/shop/grinder');
    await tester.tapAndSettle(find.text('Buy'));
    await tester.tapAndSettle(destination('Dashboard'));
    await settleStorage(tester);

    await tester.tap(find.text('Flush now'));
    await settleStorage(tester);
    await settleStorage(tester);

    expect(find.text('Sent 1 event in 1 request.'), findsOneWidget);
    expect(find.bySemanticsLabel('Sent (ever): 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Pending: 0'), findsOneWidget);
    expect(testServer.stats.accepted, 1);
  });

  testWidgets('a failing server: the purchase stays pending, and says why', (
    tester,
  ) async {
    await pumpTall(tester, initialLocation: '/shop/grinder');
    testServer.failureRate = 1;
    await tester.tapAndSettle(find.text('Buy'));
    await tester.tapAndSettle(destination('Dashboard'));
    await settleStorage(tester);

    await tester.tap(find.text('Flush now'));
    await settleStorage(tester);
    await settleStorage(tester);

    expect(
      find.text('Sending failed (server error 500). 1 event still waiting.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Pending: 1'), findsOneWidget);
  });

  testWidgets('Device offline: Flush waits; switched back on, the reconnect '
      'sends what waited', (tester) async {
    await pumpTall(tester, initialLocation: '/shop/grinder');
    await tester.tapAndSettle(find.text('Buy'));
    await tester.tapAndSettle(destination('Dashboard'));
    await settleStorage(tester);

    await tester.tap(find.text('Device offline'));
    await settleStorage(tester);
    expect(find.text('Offline (simulated)'), findsOneWidget);

    await tester.tap(find.text('Flush now'));
    await settleStorage(tester);
    await settleStorage(tester);
    expect(
      find.text("You're offline. Events wait until you're back."),
      findsOne,
    );
    expect(testServer.stats.requests, 0);

    await tester.tap(find.text('Device offline'));
    for (var i = 0; i < 3; i++) {
      await settleStorage(tester);
    }

    // No tap on Flush: the SDK saw the reconnect and uploaded by itself.
    expect(testServer.stats.accepted, 1);
    expect(find.text('Online'), findsOneWidget);
  });
}
