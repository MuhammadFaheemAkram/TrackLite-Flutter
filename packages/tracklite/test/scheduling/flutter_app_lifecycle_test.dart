import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/src/scheduling/app_lifecycle.dart';

void main() {
  testWidgets('with one: Flutter\'s lifecycle, followed', (tester) async {
    final warnings = <String>[];

    final lifecycle = createAppLifecycle(warnings.add);
    addTearDown(lifecycle.dispose);
    final seen = <bool>[];
    final subscription = lifecycle.watchForeground().listen(seen.add);
    addTearDown(subscription.cancel);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(lifecycle.isForeground, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(lifecycle, isA<FlutterAppLifecycle>());
    expect(warnings, isEmpty);
    expect(seen, [false, true]);
  });
}
