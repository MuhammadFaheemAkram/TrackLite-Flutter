import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';

/// The Dashboard's live view of the analytics queue and the network. It
/// watches the ports' streams; every stored event, upload or change of
/// network arrives here on its own.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._analytics, this._network)
    : super(const DashboardState());

  final AnalyticsService _analytics;
  final DeviceNetwork _network;
  StreamSubscription<void>? _queue;
  StreamSubscription<void>? _networkChanges;

  void start() {
    _queue ??= _analytics.watchQueue().listen(
      (queue) => emit(state.copyWith(queue: queue)),
    );
    _networkChanges ??= _network.watchStatus().listen(
      (network) => emit(state.copyWith(network: network)),
    );
  }

  /// The demo's switch: analytics behaves as if the device were offline.
  void simulateOffline(bool offline) => _network.simulateOffline(offline);

  /// Sends what is waiting now. A second tap while it runs does nothing.
  Future<void> flush() async {
    if (state.flushing) return;
    emit(state.copyWith(flushing: true));
    final outcome = await _analytics.flush();
    if (isClosed) return;
    emit(
      state.copyWith(
        flushing: false,
        lastFlush: outcome,
        flushSerial: state.flushSerial + 1,
      ),
    );
  }

  @override
  Future<void> close() async {
    // Together, not in turn (conventions §11.94).
    await Future.wait([?_queue?.cancel(), ?_networkChanges?.cancel()]);
    return super.close();
  }
}
