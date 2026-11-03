import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/home/cubit/home_state.dart';

/// Home's buttons. Each tap tracks `button_clicked` through the app's own
/// [AnalyticsService] port: this Cubit has no idea which SDK is behind it.
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._analytics) : super(const HomeState());

  final AnalyticsService _analytics;

  void tapped(HomeButton button) {
    _analytics.track('button_clicked', properties: {'button': button.id});
    emit(state.copyWith(lastTapped: button, taps: state.taps + 1));
  }
}
