/// Helpers for testing an app that uses TrackLite.
///
/// A second public library, imported only by tests, so the everyday API
/// carries nothing that exists for tests. Like `tracklite.dart`, its names
/// change only with a new major version.
library;

export 'package:tracklite/src/connectivity/network_monitor.dart'
    show FakeNetworkMonitor;
export 'package:tracklite/src/testing/tracklite_testing.dart'
    show TrackLiteTesting;
