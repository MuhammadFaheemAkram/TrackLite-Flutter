import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The app talks to the SDK through its own AnalyticsService port. Only the
// files that wire the SDK in may import it: the adapters (analytics, its debug
// tools, the demo's network monitor and server), the routes (the SDK's
// navigator observer), the DI module, the SDK's config and main(). A Cubit or a screen that imported it would tie
// the app's logic to one vendor.
void main() {
  test('only the wiring imports package:tracklite', () {
    final importers = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('.config.dart'))
        .where(
          (file) =>
              file.readAsStringSync().contains("import 'package:tracklite/"),
        )
        .map((file) => file.path)
        .toList();

    expect(
      importers,
      unorderedEquals([
        'lib/main.dart',
        'lib/app/analytics_config.dart',
        'lib/data/analytics/tracklite_analytics_service.dart',
        'lib/data/analytics/demo_network_monitor.dart',
        'lib/data/analytics/tracklite_analytics_debug.dart',
        'lib/data/analytics/fake_server_demo.dart',
        'lib/core/navigation/app_routes.dart',
        'lib/di/app_module.dart',
      ]),
    );
  });
}
