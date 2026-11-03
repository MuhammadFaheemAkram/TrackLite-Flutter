import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/recording_analytics.dart';

// The screens reach the analytics port on the real DI graph: the events a
// user's taps send, end to end (the SDK itself is replaced by a recorder).
void main() {
  tearDown(tearDownSample);

  testWidgets('Shop → a product → Buy sends one purchase', (tester) async {
    final analytics = RecordingAnalytics();
    await pumpSample(tester, initialLocation: '/shop', analytics: analytics);

    await tester.tapAndSettle(find.text('Coffee beans'));
    await tester.tapAndSettle(find.text('Buy'));

    expect(find.text('Purchase tracked: Coffee beans'), findsOneWidget);
    expect(analytics.events.where((e) => e.event != 'screen_opened'), [
      const Tracked('purchase', {
        'product_id': 'coffee-beans',
        'price': 12.5,
        'currency': 'USD',
      }),
    ]);
  });

  testWidgets("Home's buttons each send button_clicked", (tester) async {
    final analytics = RecordingAnalytics();
    await pumpSample(tester, analytics: analytics);

    await tester.tapAndSettle(find.text('Get started'));
    await tester.tapAndSettle(find.text('Share'));

    expect(analytics.events.where((e) => e.event != 'screen_opened'), [
      const Tracked('button_clicked', {'button': 'get_started'}),
      const Tracked('button_clicked', {'button': 'share'}),
    ]);
    expect(find.text('Tracked button_clicked (share). 2 so far.'), findsOne);
  });

  testWidgets('without a recorder, the real SDK takes the events', (
    tester,
  ) async {
    await pumpSample(tester, initialLocation: '/shop/grinder');

    await tester.tapAndSettle(find.text('Buy'));

    expect(find.text('Purchase tracked: Hand grinder'), findsOneWidget);
  });
}
