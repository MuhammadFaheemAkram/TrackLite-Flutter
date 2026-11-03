import 'package:flutter/foundation.dart';
import 'package:tracklite/tracklite.dart';

/// How the sample configures the SDK. `debugMode` follows the build: debug
/// builds log every SDK call, release builds are silent.
const TrackLiteConfig sampleTrackLiteConfig = TrackLiteConfig(
  apiKey: 'demo_key',
  debugMode: kDebugMode,
);
