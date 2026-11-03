import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/app_harness.dart';

void main() {
  tearDown(tearDownSample);

  group('tabs', () {
    testWidgets('the app opens on Home', (tester) async {
      await pumpSample(tester);

      expect(appBarTitled('Home'), findsOneWidget);
      expect(tester.selectedTab, 0);
    });

    testWidgets('each tab shows its own screen', (tester) async {
      await pumpSample(tester);

      for (final (index, label) in [
        (1, 'Shop'),
        (2, 'Profile'),
        (3, 'Dashboard'),
        (0, 'Home'),
      ]) {
        await tester.tapAndSettle(destination(label));
        expect(tester.selectedTab, index);
        expect(appBarTitled(label), findsOneWidget);
      }
    });
  });

  group('a product', () {
    testWidgets('opens inside the Shop tab, and Back returns to the shop', (
      tester,
    ) async {
      await pumpSample(tester, initialLocation: '/shop');

      await tester.tapAndSettle(find.text('Travel mug'));
      expect(appBarTitled('Travel mug'), findsOneWidget);
      expect(find.text(r'$24.00'), findsOneWidget);
      // Inside the tab: the bar stays, on Shop.
      expect(tester.selectedTab, 1);

      await tester.tapAndSettle(find.byType(BackButton));
      expect(appBarTitled('Shop'), findsOneWidget);
    });

    testWidgets('stays open when another tab is visited', (tester) async {
      await pumpSample(tester, initialLocation: '/shop/grinder');

      await tester.tapAndSettle(destination('Home'));
      await tester.tapAndSettle(destination('Shop'));

      expect(appBarTitled('Hand grinder'), findsOneWidget);
    });

    testWidgets('re-tapping Shop returns to the list', (tester) async {
      await pumpSample(tester, initialLocation: '/shop/grinder');

      await tester.tapAndSettle(destination('Shop'));

      expect(appBarTitled('Shop'), findsOneWidget);
    });

    testWidgets('a link opens it over the shop, so Back has somewhere to go', (
      tester,
    ) async {
      await pumpSample(tester, initialLocation: '/shop/pour-over');
      expect(appBarTitled('Pour-over kit'), findsOneWidget);

      await tester.tapAndSettle(find.byType(BackButton));

      expect(appBarTitled('Shop'), findsOneWidget);
    });

    testWidgets('a stale link says "Product not found"', (tester) async {
      await pumpSample(tester, initialLocation: '/shop/teapot');

      expect(find.text('Product not found'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });
  });

  testWidgets('an unknown location shows "Page not found", with a way back', (
    tester,
  ) async {
    await pumpSample(tester, initialLocation: '/nowhere');
    expect(find.text('Page not found'), findsOneWidget);

    await tester.tapAndSettle(find.text('Go to Home'));
    expect(appBarTitled('Home'), findsOneWidget);
  });
}
