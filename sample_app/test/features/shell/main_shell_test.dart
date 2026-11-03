import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/recording_analytics.dart';

// Tab screens are the shell's to report: at start, and on every tap of the
// bar (switching back to an open tab is no navigation at all).
void main() {
  tearDown(tearDownSample);

  List<String> screens(RecordingAnalytics analytics) => [
    for (final event in analytics.events)
      if (event.event == 'screen_opened') event.properties['screen']! as String,
  ];

  testWidgets('the first tab at start, then each tab tapped', (tester) async {
    final analytics = RecordingAnalytics();
    await pumpSample(tester, analytics: analytics);

    await tester.tapAndSettle(destination('Shop'));
    await tester.tapAndSettle(destination('Dashboard'));
    await tester.tapAndSettle(destination('Shop'));
    await tester.tapAndSettle(destination('Shop'));

    expect(screens(analytics), ['home', 'shop', 'dashboard', 'shop', 'shop']);
  });
}
