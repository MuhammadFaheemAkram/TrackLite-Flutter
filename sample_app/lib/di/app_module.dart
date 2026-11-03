import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/data/analytics/demo_network_monitor.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';

/// Registrations for objects the app doesn't construct itself.
@module
abstract class AppModule {
  /// The SDK's client, started in `main()` with `TrackLite.initialize`
  /// before anything resolves it. Registering it lets the adapter receive
  /// it through its constructor, like any other dependency.
  @lazySingleton
  TrackLiteClient get trackLite => TrackLite.instance;

  /// The device's real connectivity (tests register a fake under this
  /// name).
  @Named('device')
  @lazySingleton
  NetworkMonitor deviceMonitor() {
    final monitor = ConnectivityNetworkMonitor();
    unawaited(monitor.start());
    return monitor;
  }

  /// The SDK's monitor: the device's, plus the demo switch.
  @lazySingleton
  DemoNetworkMonitor demoNetwork(@Named('device') NetworkMonitor device) =>
      DemoNetworkMonitor(device)..start();

  /// The same object, as the Dashboard sees it.
  @lazySingleton
  DeviceNetwork deviceNetwork(DemoNetworkMonitor monitor) => monitor;
}
