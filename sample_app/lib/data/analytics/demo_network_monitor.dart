import 'dart:async';

import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';

/// The network monitor the sample gives the SDK: the device's own, plus
/// the Dashboard's "Device offline" switch.
///
/// The SDK sees only a `NetworkMonitor`. The switch is the app's business,
/// which is why the monitor is an interface: the SDK's default would know
/// nothing of a demo. Offline, the SDK attempts nothing; switched back on,
/// it sees a reconnect and uploads what waited.
class DemoNetworkMonitor implements NetworkMonitor, DeviceNetwork {
  DemoNetworkMonitor(this._device);

  final NetworkMonitor _device;
  bool _simulatingOffline = false;
  final _changes = StreamController<NetworkStatus>.broadcast();
  StreamSubscription<bool>? _deviceChanges;
  bool _deviceOnline = true;

  NetworkStatus get _status => NetworkStatus(
    deviceOnline: _deviceOnline,
    simulatingOffline: _simulatingOffline,
  );

  /// Starts following the device's connectivity.
  void start() {
    _deviceOnline = _device.isOnline;
    _deviceChanges ??= _device.watch().listen((online) {
      if (online == _deviceOnline) return;
      _deviceOnline = online;
      _changes.add(_status);
    });
  }

  @override
  bool get isOnline => _status.online;

  @override
  Stream<bool> watch() {
    // The online changes only: the switch while already offline (or the
    // connection going while simulating) changes nothing the SDK sees.
    var last = isOnline;
    final changes = _changes.stream.map((status) => status.online).where((
      online,
    ) {
      final changed = online != last;
      last = online;
      return changed;
    });
    return _led(() => last = isOnline, changes);
  }

  @override
  Stream<NetworkStatus> watchStatus() => _led(() => _status, _changes.stream);

  /// [changes], led by [current]'s value at the moment of listening, and
  /// subscribed as it is listened to (an `async*` generator would miss a
  /// change made before its first value was delivered).
  static Stream<T> _led<T>(T Function() current, Stream<T> changes) {
    StreamSubscription<T>? subscription;
    late final StreamController<T> out;
    out = StreamController<T>(
      onListen: () {
        out.add(current());
        subscription = changes.listen(out.add, onError: out.addError);
      },
      onCancel: () async {
        await subscription?.cancel();
        await out.close();
      },
    );
    return out.stream;
  }

  /// Stops following the device.
  Future<void> dispose() async {
    await _deviceChanges?.cancel();
    await _changes.close();
  }

  @override
  void simulateOffline(bool offline) {
    if (offline == _simulatingOffline) return;
    _simulatingOffline = offline;
    _changes.add(_status);
  }
}
