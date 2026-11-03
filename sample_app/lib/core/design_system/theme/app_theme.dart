import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/theme/app_colors.dart';
import 'package:tracklite_sample/core/design_system/theme/app_radius.dart';

/// Builds the app's Material 3 light and dark themes.
///
/// Screens style themselves through `Theme.of(context)`, never with
/// hard-coded colors, so restyling the app means changing [seedColor] and the
/// component themes here, and nothing else.
abstract final class AppTheme {
  /// An indigo: one color the whole palette is derived from.
  static const Color seedColor = Color(0xFF3F51B5);

  static ThemeData light() => _fromSeed(Brightness.light);

  static ThemeData dark() => _fromSeed(Brightness.dark);

  static ThemeData _fromSeed(Brightness brightness) => _fromScheme(
    ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      // `fidelity` keeps the primary color close to the seed; the default
      // variant (`tonalSpot`) would noticeably mute it.
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ),
  );

  static ThemeData _fromScheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      extensions: [
        if (colorScheme.brightness == Brightness.light)
          AppColors.light
        else
          AppColors.dark,
      ],
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.medium)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      // A row's icon stays level with its title when large text wraps the
      // row onto several lines, instead of drifting to the row's middle.
      listTileTheme: const ListTileThemeData(
        titleAlignment: ListTileTitleAlignment.titleHeight,
      ),
    );
  }
}
