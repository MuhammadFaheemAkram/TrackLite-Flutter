import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';

double contrast(Color a, Color b) {
  final (hi, lo) = (a.computeLuminance(), b.computeLuminance());
  return hi > lo ? (hi + 0.05) / (lo + 0.05) : (lo + 0.05) / (hi + 0.05);
}

void main() {
  group('AppTheme', () {
    test('builds Material 3 light and dark themes from the seed', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();

      expect(light.useMaterial3, isTrue);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });

    test('the primary color stays close to the seed (fidelity)', () {
      final primary = HSLColor.fromColor(AppTheme.light().colorScheme.primary);
      final seed = HSLColor.fromColor(AppTheme.seedColor);

      expect((primary.hue - seed.hue).abs(), lessThan(10));
      // As vivid as the seed: the default and neutral variants keep the hue
      // but drain the color.
      expect(primary.saturation, greaterThanOrEqualTo(seed.saturation * 0.8));
    });

    test('registers the matching AppColors for each brightness', () {
      expect(AppTheme.light().extension<AppColors>(), same(AppColors.light));
      expect(AppTheme.dark().extension<AppColors>(), same(AppColors.dark));
    });

    test('list rows keep their icon level with the title at large text', () {
      expect(
        AppTheme.light().listTileTheme.titleAlignment,
        ListTileTitleAlignment.titleHeight,
      );
    });
  });

  group('AppColors', () {
    List<Color> tokens(AppColors c) => [
      c.pending,
      c.sending,
      c.sent,
      c.failed,
      c.offline,
    ];

    test('lerp interpolates every token', () {
      final mid = AppColors.light.lerp(AppColors.dark, 0.5);

      final (light, dark) = (tokens(AppColors.light), tokens(AppColors.dark));
      expect(tokens(mid), [
        for (var i = 0; i < light.length; i++)
          Color.lerp(light[i], dark[i], 0.5),
      ]);
    });

    test('lerp towards a missing extension keeps the current colors', () {
      expect(AppColors.light.lerp(null, 0.5), same(AppColors.light));
    });

    test('copyWith replaces only the given tokens', () {
      const purple = Color(0xFF7B1FA2);
      final copy = AppColors.light.copyWith(failed: purple);

      expect(copy.failed, purple);
      expect(copy.pending, AppColors.light.pending);
      expect(copy.sending, AppColors.light.sending);
      expect(copy.sent, AppColors.light.sent);
      expect(copy.offline, AppColors.light.offline);
    });

    test('every status has its own color, in both themes', () {
      for (final colors in [AppColors.light, AppColors.dark]) {
        expect(tokens(colors).toSet(), hasLength(5));
      }
    });

    testWidgets('context.appColors reads the current theme', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              colors = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors, same(AppColors.dark));
    });
  });

  // WCAG contrast checks, so a color tweak can't silently make a label
  // unreadable. The status colors are text and icon colors on the page, on
  // cards and on filled surfaces (a chip), so each must reach AA (4.5:1) on
  // all of them.
  group('Contrast in both themes', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final name = theme.colorScheme.brightness.name;
      final colors = theme.extension<AppColors>()!;
      final scheme = theme.colorScheme;
      final surfaces = {
        'the page': scheme.surface,
        'a card': scheme.surfaceContainerLow,
        'a filled surface': scheme.surfaceContainerHighest,
      };

      for (final (token, color) in [
        ('pending', colors.pending),
        ('sending', colors.sending),
        ('sent', colors.sent),
        ('failed', colors.failed),
        ('offline', colors.offline),
      ]) {
        for (final MapEntry(key: surface, value: background)
            in surfaces.entries) {
          test('$name: $token text on $surface meets AA (4.5:1)', () {
            expect(contrast(color, background), greaterThanOrEqualTo(4.5));
          });
        }
      }
    }
  });
}
