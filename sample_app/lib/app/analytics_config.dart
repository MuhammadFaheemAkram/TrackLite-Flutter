import 'package:flutter/foundation.dart';
import 'package:tracklite/tracklite.dart';

/// How the sample configures the SDK.
///
/// - `debugMode` follows the build: debug builds log every SDK call,
///   release builds are silent.
/// - The [transport] is the SDK's fake server, made by the app so the
///   Dashboard can set its failure rate and speed.
/// - The [networkMonitor] is the sample's: the device's network plus the
///   Dashboard's "Device offline" switch.
TrackLiteConfig sampleTrackLiteConfig({
  required NetworkMonitor networkMonitor,
  required AnalyticsTransport transport,
}) => TrackLiteConfig(
  apiKey: 'demo_key',
  debugMode: kDebugMode,
  networkMonitor: networkMonitor,
  transport: transport,
);
