import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';

/// The demo's [DemoBackend]: the knobs of the SDK's fake server, which the
/// sample creates and gives the SDK as its transport (so it can turn them).
@LazySingleton(as: DemoBackend)
class FakeServerDemo implements DemoBackend {
  FakeServerDemo(this._server)
    : _failures = _closest(
        ServerFailures.values,
        (f) => (f.rate - _server.failureRate).abs(),
      ),
      _speed = _closest(
        ServerSpeed.values,
        (s) => (s.latency - _server.latency).inMicroseconds.abs(),
      );

  final FakeAnalyticsServer _server;
  ServerFailures _failures;
  ServerSpeed _speed;
  final _settings = StreamController<void>.broadcast();

  @override
  Stream<DemoServerState> watch() => Stream.multi((out) {
    var stats = _server.stats;
    void emit() => out.add(_stateOf(stats));
    final subscriptions = [
      _server.watchStats().listen((latest) {
        stats = latest;
        emit();
      }),
      _settings.stream.listen((_) => emit()),
    ];
    out.onCancel = () =>
        Future.wait([for (final s in subscriptions) s.cancel()]);
  });

  @override
  void setFailures(ServerFailures failures) {
    _failures = failures;
    _server.failureRate = failures.rate;
    _settings.add(null);
  }

  @override
  void setSpeed(ServerSpeed speed) {
    _speed = speed;
    _server.latency = speed.latency;
    _settings.add(null);
  }

  DemoServerState _stateOf(FakeServerStats stats) => DemoServerState(
    failures: _failures,
    speed: _speed,
    requests: stats.requests,
    accepted: stats.accepted,
    duplicates: stats.duplicates,
    serverFailures: stats.failures,
  );

  static T _closest<T>(List<T> values, num Function(T value) distance) =>
      values.reduce((a, b) => distance(a) <= distance(b) ? a : b);
}
