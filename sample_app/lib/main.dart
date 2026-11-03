import 'package:material_ui/material_ui.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/app/analytics_config.dart';
import 'package:tracklite_sample/app/tracklite_sample_app.dart';
import 'package:tracklite_sample/di/injection.dart';

Future<void> main() async {
  // Bindings must exist before any setup touches plugins.
  WidgetsFlutterBinding.ensureInitialized();
  // The SDK starts first, as the README tells every host app: events
  // tracked from the first screen on have somewhere to go.
  await TrackLite.initialize(sampleTrackLiteConfig);
  configureDependencies();
  runApp(const TrackLiteSampleApp());
}
