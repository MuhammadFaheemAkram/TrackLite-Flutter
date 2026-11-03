import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite_sample/data/analytics/demo_network_monitor.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';

void main() {
  late FakeNetworkMonitor device;
  late DemoNetworkMonitor monitor;

  setUp(() {
    device = FakeNetworkMonitor();
    monitor = DemoNetworkMonitor(device)..start();
  });
  tearDown(() => monitor.dispose());

  test('online only with a connection and the switch off', () async {
    expect(monitor.isOnline, isTrue);

    monitor.simulateOffline(true);
    expect(monitor.isOnline, isFalse);

    monitor.simulateOffline(false);
    device.online = false;
    await pumpEventQueue();
    expect(monitor.isOnline, isFalse);
  });

  test("the SDK's stream: online changes only, none repeated", () async {
    final seen = <bool>[];
    final subscription = monitor.watch().listen(seen.add);
    await pumpEventQueue();

    monitor.simulateOffline(true);
    await pumpEventQueue();
    // Already offline (simulated): losing the connection changes nothing
    // the SDK sees.
    device.online = false;
    await pumpEventQueue();
    monitor.simulateOffline(false);
    await pumpEventQueue();
    device.online = true;
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen, [true, false, true]);
  });

  test("the Dashboard's stream: both facts, each change", () async {
    final seen = <NetworkStatus>[];
    final subscription = monitor.watchStatus().listen(seen.add);
    await pumpEventQueue();

    monitor.simulateOffline(true);
    device.online = false;
    await pumpEventQueue();
    await subscription.cancel();

    expect(seen, const [
      NetworkStatus(deviceOnline: true),
      NetworkStatus(deviceOnline: true, simulatingOffline: true),
      NetworkStatus(deviceOnline: false, simulatingOffline: true),
    ]);
  });

  test('dispose stops following the device', () async {
    await monitor.dispose();

    expect(device.hasListener, isFalse);
    // A fresh one for tearDown.
    monitor = DemoNetworkMonitor(device);
  });
}
