import 'package:freezed_annotation/freezed_annotation.dart';

part 'demo_backend.freezed.dart';

/// How often the demo server fails a request.
enum ServerFailures {
  none(0, '0 %'),
  some(0.1, '10 %'),
  half(0.5, '50 %'),
  all(1, '100 %');

  const ServerFailures(this.rate, this.label);

  final double rate;
  final String label;
}

/// How fast the demo server answers.
enum ServerSpeed {
  fast(Duration(milliseconds: 100), 'Fast'),
  normal(Duration(milliseconds: 800), 'Normal'),
  slow(Duration(seconds: 3), 'Slow');

  const ServerSpeed(this.latency, this.label);

  final Duration latency;
  final String label;
}

/// The demo server's settings and what it has seen.
@freezed
abstract class DemoServerState with _$DemoServerState {
  const factory DemoServerState({
    required ServerFailures failures,
    required ServerSpeed speed,
    @Default(0) int requests,
    @Default(0) int accepted,
    @Default(0) int duplicates,
    @Default(0) int serverFailures,
  }) = _DemoServerState;
}

/// The demo's backend controls: the fake analytics server's failure rate
/// and speed, and what it has received. Only the sample has these; a real
/// app's server isn't a knob on a screen.
abstract interface class DemoBackend {
  /// The settings and stats now, then after every change.
  Stream<DemoServerState> watch();

  void setFailures(ServerFailures failures);

  void setSpeed(ServerSpeed speed);
}
