import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_state.dart';

/// Profile: a pretend sign-in that only ties analytics to a user id. The
/// identity shown comes back from analytics itself, so the screen shows
/// what the events will carry.
@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._analytics) : super(const ProfileState());

  final AnalyticsService _analytics;
  StreamSubscription<void>? _identity;

  void start() {
    _identity ??= _analytics.watchIdentity().listen(
      (identity) => emit(state.copyWith(identity: identity)),
    );
  }

  /// Signs in as [userId] (trimmed; a blank one is ignored). The user id
  /// is set first, so `signed_in` already carries it.
  void signIn(String userId) {
    final id = userId.trim();
    if (id.isEmpty) return;
    _analytics
      ..identify(id)
      ..track('signed_in');
  }

  /// Signs out. `signed_out` is tracked first, while the events still
  /// carry the user; then analytics forgets them (and starts a new
  /// anonymous id).
  void signOut() {
    _analytics
      ..track('signed_out')
      ..reset();
  }

  @override
  Future<void> close() async {
    await _identity?.cancel();
    return super.close();
  }
}
