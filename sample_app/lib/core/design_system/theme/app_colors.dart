import 'package:material_ui/material_ui.dart';

/// Colors with a meaning that Material's [ColorScheme] has no slot for: an
/// event's status in the SDK's queue, and the device being offline.
///
/// A [ThemeExtension] travels inside [ThemeData], so the light and dark
/// variants switch automatically (and animate via [lerp]) when the theme
/// changes. Widgets ask for an *intent* (`failed`, `offline`) instead of
/// hard-coding raw colors.
///
/// Each is a text and icon color on the page, on cards and on filled
/// surfaces, so each must reach WCAG AA (4.5:1) against those surfaces in
/// both themes (checked by a test). Color is never the only signal: a status
/// always has an icon and a word too.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.pending,
    required this.sending,
    required this.sent,
    required this.failed,
    required this.offline,
  });

  /// Stored, waiting for an upload.
  final Color pending;

  /// In an upload that is in flight.
  final Color sending;

  /// Accepted by the server.
  final Color sent;

  /// Given up on after too many server errors.
  final Color failed;

  /// The device is offline (or the demo says so).
  final Color offline;

  static const light = AppColors(
    pending: Color(0xFF7A4E00),
    sending: Color(0xFF1D5FA8),
    sent: Color(0xFF146C2E),
    failed: Color(0xFFB3261E),
    offline: Color(0xFF44546A),
  );

  static const dark = AppColors(
    pending: Color(0xFFFFC56B),
    sending: Color(0xFF9ECAFF),
    sent: Color(0xFF86D993),
    failed: Color(0xFFFF9C92),
    offline: Color(0xFFB7C6DB),
  );

  @override
  AppColors copyWith({
    Color? pending,
    Color? sending,
    Color? sent,
    Color? failed,
    Color? offline,
  }) {
    return AppColors(
      pending: pending ?? this.pending,
      sending: sending ?? this.sending,
      sent: sent ?? this.sent,
      failed: failed ?? this.failed,
      offline: offline ?? this.offline,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      pending: Color.lerp(pending, other.pending, t)!,
      sending: Color.lerp(sending, other.sending, t)!,
      sent: Color.lerp(sent, other.sent, t)!,
      failed: Color.lerp(failed, other.failed, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AppColors>()!`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
