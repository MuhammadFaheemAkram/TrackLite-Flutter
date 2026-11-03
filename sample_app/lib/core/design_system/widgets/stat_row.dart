import 'package:material_ui/material_ui.dart';

/// One labelled number: an icon, a word and a count, read as one phrase by
/// screen readers ("Pending: 12"). The color is never the only signal: the
/// icon and the word say the same.
class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;

  /// The icon's color (a status color); the theme's muted one by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: ListTile(
          leading: Icon(
            icon,
            color: color ?? theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(label),
          trailing: Text(value, style: theme.textTheme.titleMedium),
        ),
      ),
    );
  }
}
