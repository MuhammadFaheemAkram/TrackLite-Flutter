import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/theme/app_icon_size.dart';
import 'package:tracklite_sample/core/design_system/theme/app_radius.dart';
import 'package:tracklite_sample/core/design_system/theme/app_spacing.dart';

/// A small status: an icon and a word in a status color, on an outline.
/// The color is never the only signal: the icon and the word say the same.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.small)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xSmall,
          vertical: AppSpacing.xxSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSize.small, color: color),
            const SizedBox(width: AppSpacing.xxSmall),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
