// The smallest integration: initialize once, then track from anywhere.
import 'package:flutter/widgets.dart';
import 'package:tracklite/tracklite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrackLite.initialize(
    const TrackLiteConfig(apiKey: 'demo_key', debugMode: true),
  );

  TrackLite.setUserId('user_123');
  TrackLite.track('screen_opened', properties: {'screen': 'Home'});
  TrackLite.track('purchase', properties: {'price': 20, 'currency': 'USD'});

  final result = await TrackLite.flush();
  debugPrint('flush: $result');

  TrackLite.clearUser();
  await TrackLite.shutdown();
}
