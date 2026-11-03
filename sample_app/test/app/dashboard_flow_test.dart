import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';

import '../helpers/app_harness.dart';

// The real SDK, on an in-memory database and the instant test server: what a
// tap tracks is stored, the Dashboard shows it from the SDK's own streams,
// and its buttons move it. Opening a tab is an event too (the shell tracks
// it), so these flows check their own events, by name, not totals.
void main() {
  tearDown(tearDownSample);

  // Phone width, but tall enough for the whole Dashboard: a lazy list
  // builds only the rows that show.
  Future<void> pumpTall(WidgetTester tester, {String? initialLocation}) async {
    await pumpSample(tester, initialLocation: initialLocation);
    tester.view.physicalSize = const Size(390 * 3, 5000 * 3);
    await tester.pump();
  }

  Future<void> settleStorage(WidgetTester tester) async {
    // The SDK writes on its own schedule (a microtask, then the database),
    // and its stats come through a few async steps (a query, the last
    // upload's row, three streams combined): give real time a few turns so
    // each step lands.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }
  }

  /// The state chip of the Recent events row named [event] (unique).
  String stateOf(WidgetTester tester, String event) {
    final row = find.ancestor(
      of: find.text(event),
      matching: find.byType(ListTile),
    );
    return tester
        .widget<StatusChip>(
          find.descendant(of: row, matching: find.byType(StatusChip)),
        )
        .label;
  }

  /// What the SDK stored, newest first, read straight from it.
  Future<List<TrackLiteEvent>> stored(WidgetTester tester) async =>
      (await tester.runAsync(
        () => TrackLite.debug.watchRecentEvents(limit: 50).first,
      ))!;

  Future<void> buyThenDashboard(WidgetTester tester) async {
    await pumpTall(tester, initialLocation: '/shop/grinder');
    await tester.tapAndSettle(find.text('Buy'));
    await settleStorage(tester);
    await tester.tapAndSettle(destination('Dashboard'));
    await settleStorage(tester);
  }

  testWidgets("a fresh install: the Dashboard's own screen is the first "
      'event, from an anonymous id', (tester) async {
    await pumpTall(tester, initialLocation: '/dashboard');
    await settleStorage(tester);

    expect(find.bySemanticsLabel('Tracked: 1'), findsOneWidget);
    expect(find.text('screen_opened'), findsOneWidget);
    expect(find.textContaining('screen: dashboard'), findsOneWidget);
    expect(find.text('Anonymous'), findsOneWidget);
  });

  testWidgets('Buy, then the Dashboard: the purchase is stored, pending', (
    tester,
  ) async {
    await buyThenDashboard(tester);

    expect(stateOf(tester, 'purchase'), 'Pending');
    expect(find.textContaining('product_id: grinder'), findsOneWidget);
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

    expect(find.text('button_clicked'), findsNWidgets(2));
  });

  testWidgets('Flush now sends the queue: the purchase is sent', (
    tester,
  ) async {
    await buyThenDashboard(tester);

    await tester.tap(find.text('Flush now'));
    await settleStorage(tester);

    expect(
      find.textContaining(RegExp(r'^Sent \d+ events in 1 request')),
      findsOne,
    );
    expect(stateOf(tester, 'purchase'), 'Sent');
    expect(find.bySemanticsLabel('Pending: 0'), findsOneWidget);
    expect(find.text('Flush · Uploaded'), findsOneWidget);
  });

  testWidgets('a failing server: the purchase waits for its retry, and the '
      'error says why', (tester) async {
    await buyThenDashboard(tester);
    await tester.tap(find.text('100 %'));
    await settleStorage(tester);

    await tester.tap(find.text('Flush now'));
    await settleStorage(tester);

    expect(find.textContaining('Sending failed (server error 500)'), findsOne);
    expect(stateOf(tester, 'purchase'), 'Pending');
    expect(find.textContaining('1 server error · retry at'), findsWidgets);
    expect(find.bySemanticsLabel('Requests failed: 1'), findsOneWidget);
  });

  testWidgets('past the retries, Retry failed brings the events back, and '
      'they go once the server recovers', (tester) async {
    await buyThenDashboard(tester);
    await tester.tap(find.text('100 %'));
    await settleStorage(tester);

    // maxRetries is 5: the sixth server error gives up. Flush ignores the
    // backoff, so six taps get there at once.
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Flush now'));
      await settleStorage(tester);
    }
    expect(stateOf(tester, 'purchase'), 'Failed');

    await tester.tap(find.text('Retry failed'));
    await settleStorage(tester);
    expect(find.textContaining('failed events back in the queue'), findsOne);
    expect(stateOf(tester, 'purchase'), 'Pending');

    await tester.tap(find.text('0 %'));
    await tester.tap(find.text('Flush now'));
    await settleStorage(tester);
    expect(stateOf(tester, 'purchase'), 'Sent');
  });

  testWidgets('Track 100 events: the SDK sends full batches by itself', (
    tester,
  ) async {
    await pumpTall(tester, initialLocation: '/dashboard');
    await settleStorage(tester);

    await tester.tap(find.text('Track 100 events'));
    for (var i = 0; i < 4; i++) {
      await settleStorage(tester);
    }

    // No tap on Flush: each full batch of 20 started an upload.
    expect(testServer.stats.accepted, greaterThanOrEqualTo(100));
    expect(find.textContaining('Full batch · Uploaded'), findsWidgets);
  });

  testWidgets('Device offline: Flush waits; switched back on, the reconnect '
      'sends what waited', (tester) async {
    await buyThenDashboard(tester);

    await tester.tap(find.text('Device offline'));
    await settleStorage(tester);
    expect(find.text('Offline (simulated)'), findsOneWidget);

    await tester.tap(find.text('Flush now'));
    await settleStorage(tester);
    expect(
      find.text("You're offline. Events wait until you're back."),
      findsOne,
    );
    expect(testServer.stats.requests, 0);

    await tester.tap(find.text('Device offline'));
    await settleStorage(tester);

    // No tap on Flush: the SDK saw the reconnect and uploaded by itself.
    expect(stateOf(tester, 'purchase'), 'Sent');
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Reconnected · Uploaded'), findsOneWidget);
  });

  group('screen tracking', () {
    testWidgets('a tab by the shell; a product, and Back to the shop, by the '
        "SDK's navigator observer", (tester) async {
      await pumpTall(tester, initialLocation: '/shop');
      await tester.tapAndSettle(find.text('Travel mug'));
      await tester.tapAndSettle(find.byType(BackButton));

      final screens = [
        for (final event in (await stored(tester)).reversed)
          if (event.name == 'screen_opened') event.properties['screen'],
      ];
      expect(screens, ['shop', 'product', 'shop']);
    });
  });

  group('sign in and out', () {
    testWidgets('signed_in carries the user; signed_out too; then a new '
        'anonymous id', (tester) async {
      await pumpTall(tester, initialLocation: '/profile');
      await settleStorage(tester);
      final anonymousBefore = (await stored(tester)).first.anonymousId;

      await tester.enterText(find.byType(TextField), 'alex');
      // Sign in turns on once the field has text: let it rebuild first.
      await tester.pump();
      await tester.tapAndSettle(find.text('Sign in'));
      await settleStorage(tester);
      expect(find.text('alex'), findsOneWidget);

      await tester.tapAndSettle(find.text('Sign out'));
      await settleStorage(tester);
      expect(find.text('Signed out'), findsOneWidget);

      final events = {for (final e in await stored(tester)) e.name: e};
      expect(events['signed_in']?.userId, 'alex');
      expect(events['signed_out']?.userId, 'alex');
      expect(events['signed_out']?.anonymousId, anonymousBefore);
      expect(find.text(anonymousBefore), findsNothing);
    });
  });
}
