import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

/// The plugin's platform side, scripted (conventions §11.92: a fresh one
/// per test).
class _FakePlatform extends ConnectivityPlatform {
  List<ConnectivityResult> now = [ConnectivityResult.wifi];
  final changes = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => now;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;

  Future<void> dispose() => changes.close();
}

void main() {
  late _FakePlatform platform;

  setUp(() {
    platform = _FakePlatform();
    addTearDown(platform.dispose);
    ConnectivityPlatform.instance = platform;
  });

  group('ConnectivityNetworkMonitor', () {
    test('online until it knows, then what the plugin says', () async {
      platform.now = [ConnectivityResult.none];
      final monitor = ConnectivityNetworkMonitor();
      addTearDown(monitor.dispose);

      expect(monitor.isOnline, isTrue);
      await monitor.start();
      expect(monitor.isOnline, isFalse);
    });

    test('any connection is online; only "none" is offline', () async {
      final monitor = ConnectivityNetworkMonitor();
      addTearDown(monitor.dispose);
      await monitor.start();
      final seen = <bool>[];
      final subscription = monitor.watch().listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      for (final results in [
        [ConnectivityResult.none],
        [ConnectivityResult.mobile],
        [ConnectivityResult.mobile, ConnectivityResult.vpn],
        [ConnectivityResult.none],
        [ConnectivityResult.ethernet],
      ]) {
        platform.changes.add(results);
        await pumpEventQueue();
      }

      // The current value first, then each change (repeats are dropped).
      expect(seen, [true, false, true, false, true]);
    });

    test('a plugin that fails leaves it online, and nothing thrown', () async {
      ConnectivityPlatform.instance = _ThrowingPlatform();
      final monitor = ConnectivityNetworkMonitor();
      addTearDown(monitor.dispose);

      await expectLater(monitor.start(), completes);
      expect(monitor.isOnline, isTrue);
    });
  });

  group('FakeNetworkMonitor', () {
    test('watch: the current value, then each change', () async {
      final monitor = FakeNetworkMonitor();
      final seen = <bool>[];
      final subscription = monitor.watch().listen(seen.add);
      await pumpEventQueue();

      monitor
        ..online = false
        ..online = false
        ..online = true;
      await pumpEventQueue();
      await subscription.cancel();

      expect(seen, [true, false, true]);
      expect(monitor.hasListener, isFalse);
    });

    test('can start offline', () {
      expect(FakeNetworkMonitor(online: false).isOnline, isFalse);
    });
  });
}

class _ThrowingPlatform extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      Future.error(StateError('no plugin'));

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      throw StateError('no plugin');
}
