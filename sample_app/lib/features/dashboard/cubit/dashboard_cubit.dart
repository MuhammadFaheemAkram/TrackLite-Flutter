import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';

/// The Dashboard: a live view of analytics (the queue, recent events, the
/// upload log), the network and the demo server, and the actions that make
/// each of them move. Everything arrives through the ports' streams; the
/// actions only ask, and the streams show what happened.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._debug, this._analytics, this._network, this._backend)
    : super(const DashboardState());

  final AnalyticsDebug _debug;
  final AnalyticsService _analytics;
  final DeviceNetwork _network;
  final DemoBackend _backend;
  final _subscriptions = <StreamSubscription<void>>[];

  /// How many events "Track 100 events" tracks: five full batches.
  static const burst = 100;

  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions.addAll([
      _debug.watchQueue().listen((queue) => emit(state.copyWith(queue: queue))),
      _debug.watchRecentEvents().listen(
        (events) => emit(state.copyWith(recentEvents: events)),
      ),
      _debug.watchUploads().listen(
        (runs) => emit(state.copyWith(uploads: runs)),
      ),
      _network.watchStatus().listen(
        (network) => emit(state.copyWith(network: network)),
      ),
      _backend.watch().listen((server) => emit(state.copyWith(server: server))),
    ]);
  }

  /// The demo's switch: analytics behaves as if the device were offline.
  void simulateOffline(bool offline) => _network.simulateOffline(offline);

  void setServerFailures(ServerFailures failures) =>
      _backend.setFailures(failures);

  void setServerSpeed(ServerSpeed speed) => _backend.setSpeed(speed);

  /// Sends what is waiting now. A second tap while it runs does nothing.
  Future<void> flush() async {
    if (state.flushing) return;
    emit(state.copyWith(flushing: true));
    final outcome = await _debug.flush();
    if (isClosed) return;
    _say(DashboardEffect.flushed(outcome), flushing: false);
  }

  /// Puts the failed events back in the queue; the next upload sends them.
  Future<void> retryFailed() async {
    final count = await _debug.retryFailed();
    if (isClosed) return;
    _say(DashboardEffect.retried(count));
  }

  /// Tracks [burst] events at once: with batches of 20, a full batch is
  /// ready after every 20, and the SDK uploads them by itself.
  void trackBurst() {
    for (var i = 1; i <= burst; i++) {
      _analytics.track('demo_burst', properties: {'n': i});
    }
    _say(const DashboardEffect.tracked(burst));
  }

  void _say(DashboardEffect effect, {bool? flushing}) => emit(
    state.copyWith(
      effect: effect,
      effectSerial: state.effectSerial + 1,
      flushing: flushing ?? state.flushing,
    ),
  );

  @override
  Future<void> close() async {
    // Together, not in turn (conventions §11.94).
    await Future.wait([for (final s in _subscriptions) s.cancel()]);
    return super.close();
  }
}
