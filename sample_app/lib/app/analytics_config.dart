import 'package:flutter/foundation.dart';
import 'package:tracklite/tracklite.dart';

/// How the sample configures the SDK.
///
/// - `debugMode` follows the build: debug builds log every SDK call,
///   release builds are silent.
/// - No transport: the SDK's own fake server, with its demo latency and
///   failure rate.
/// - The [networkMonitor] is the sample's: the device's network plus the
///   Dashboard's "Device offline" switch.
TrackLiteConfig sampleTrackLiteConfig({
  required NetworkMonitor networkMonitor,
}) => TrackLiteConfig(
  apiKey: 'demo_key',
  debugMode: kDebugMode,
  networkMonitor: networkMonitor,
);
