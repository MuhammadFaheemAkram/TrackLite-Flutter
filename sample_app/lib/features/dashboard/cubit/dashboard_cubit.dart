import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';

/// The Dashboard's live view of the analytics queue. It watches the port's
/// stream; every stored event, rejection or identity change arrives here on
/// its own.
@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._analytics) : super(const DashboardState());

  final AnalyticsService _analytics;
  StreamSubscription<void>? _queue;

  void start() {
    _queue ??= _analytics.watchQueue().listen(
      (queue) => emit(state.copyWith(queue: queue)),
    );
  }

  @override
  Future<void> close() async {
    await _queue?.cancel();
    return super.close();
  }
}
