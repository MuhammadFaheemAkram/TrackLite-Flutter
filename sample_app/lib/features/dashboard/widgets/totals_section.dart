import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';

/// The running totals, and who the events are about.
class TotalsSection extends StatelessWidget {
  const TotalsSection({super.key, required this.queue});

  final QueueStats queue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Totals'),
        StatRow(
          icon: Icons.functions,
          label: 'Tracked',
          value: '${queue.tracked}',
        ),
        StatRow(
          icon: Icons.delete_sweep_outlined,
          label: 'Dropped (queue full)',
          value: '${queue.dropped}',
        ),
        StatRow(
          icon: Icons.block,
          label: 'Rejected (invalid)',
          value: '${queue.rejected}',
        ),
        const SectionHeader('Identity'),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('User id'),
          subtitle: Text(queue.userId ?? 'Anonymous'),
        ),
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Anonymous id'),
          subtitle: Text(queue.anonymousId),
        ),
      ],
    );
  }
}
