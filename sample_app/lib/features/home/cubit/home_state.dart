import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// A button on Home, and what tapping it sends.
enum HomeButton {
  getStarted('get_started', 'Get started'),
  share('share', 'Share'),
  rate('rate', 'Rate the app');

  const HomeButton(this.id, this.label);

  /// The value of the event's `button` property.
  final String id;
  final String label;
}

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    /// The last button tapped, so the screen can show what it sent.
    HomeButton? lastTapped,
    @Default(0) int taps,
  }) = _HomeState;
}
