import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/app_harness.dart';

// Every screen, in light and dark, with text at 200 %: no layout overflows
// (an overflow fails the test), tap targets of at least 48 × 48, a label on
// everything tappable, and readable text contrast. A new screen, or a new
// state of one, gets a stop here.
void main() {
  tearDown(tearDownSample);

  for (final brightness in Brightness.values) {
    group('${brightness.name} theme, text at 200 %', () {
      for (final (name, location, Future<void> Function(WidgetTester)? act) in [
        ('Home', '/home', null),
        (
          'Home, after a tap',
          '/home',
          (tester) => tester.tapAndSettle(find.text('Share')),
        ),
        ('Shop', '/shop', null),
        ('Product', '/shop/grinder', null),
        (
          'Product, after Buy',
          '/shop/grinder',
          (tester) => tester.tapAndSettle(find.text('Buy')),
        ),
        ('Product not found', '/shop/teapot', null),
        ('Profile', '/profile', null),
        ('Dashboard, an empty queue', '/dashboard', null),
        (
          'Dashboard, after a flush',
          '/dashboard',
          (tester) async {
            await tester.tap(find.text('Flush now'));
            await tester.runAsync(() => Future<void>.delayed(Duration.zero));
            await tester.pumpAndSettle();
          },
        ),
        (
          'Dashboard, with events',
          '/shop/grinder',
          (tester) async {
            await tester.tapAndSettle(find.text('Buy'));
            await tester.tapAndSettle(destination('Dashboard'));
          },
        ),
        ('Page not found', '/nowhere', null),
      ]) {
        testWidgets(name, (tester) async {
          tester.platformDispatcher
            ..textScaleFactorTestValue = 2
            ..platformBrightnessTestValue = brightness;
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          await pumpSample(tester, initialLocation: location);
          // Phone width, but tall enough to lay out every item of a long
          // list: the checks see only what is built.
          tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
          await tester.pumpAndSettle();
          await act?.call(tester);
          // Let the SDK's writes and the Dashboard's stream land.
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(Scaffold).last);
          expect(MediaQuery.textScalerOf(context).scale(10), 20);
          expect(Theme.of(context).brightness, brightness);

          final handle = tester.ensureSemantics();
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    });
  }

  testWidgets('the tab labels keep their size at any text setting (a long '
      'press shows them)', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await pumpSample(tester);

    final label = destination('Dashboard');
    expect(MediaQuery.textScalerOf(tester.element(label)).scale(10), 10);

    final before = find.text('Dashboard').evaluate().length;
    await tester.longPress(label);
    await tester.pumpAndSettle();
    // One more: the tooltip over the bar.
    expect(find.text('Dashboard'), findsNWidgets(before + 1));
  });
}
