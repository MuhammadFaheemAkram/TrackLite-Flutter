import 'package:material_ui/material_ui.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/app/analytics_config.dart';
import 'package:tracklite_sample/app/tracklite_sample_app.dart';
import 'package:tracklite_sample/data/analytics/demo_network_monitor.dart';
import 'package:tracklite_sample/di/injection.dart';

Future<void> main() async {
  // Bindings must exist before any setup touches plugins.
  WidgetsFlutterBinding.ensureInitialized();
  // The graph first (nothing in it starts the SDK: the client is resolved
  // lazily), so the SDK can be given the app's network monitor.
  configureDependencies();
  // The SDK starts before the first screen, as the README tells every host
  // app: events tracked from then on have somewhere to go.
  await TrackLite.initialize(
    sampleTrackLiteConfig(networkMonitor: getIt<DemoNetworkMonitor>()),
  );
  runApp(const TrackLiteSampleApp());
}
