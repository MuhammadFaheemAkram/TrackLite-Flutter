import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';

/// The queue's counts by state, and the actions on it.
class QueueSection extends StatelessWidget {
  const QueueSection({super.key, required this.queue, required this.flushing});

  final QueueStats queue;
  final bool flushing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final cubit = context.read<DashboardCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Queue'),
        // Shown while any upload runs, a flush or an automatic one.
        SizedBox(
          height: 4,
          child: queue.uploading
              ? const LinearProgressIndicator(semanticsLabel: 'Uploading')
              : null,
        ),
        StatRow(
          icon: Icons.schedule,
          label: 'Pending',
          value: '${queue.pending}',
          color: colors.pending,
        ),
        StatRow(
          icon: Icons.cloud_upload_outlined,
          label: 'Sending',
          value: '${queue.sending}',
          color: colors.sending,
        ),
        StatRow(
          icon: Icons.cloud_done_outlined,
          label: 'Sent (ever)',
          value: '${queue.sent}',
          color: colors.sent,
        ),
        StatRow(
          icon: Icons.error_outline,
          label: 'Failed',
          value: '${queue.failed}',
          color: colors.failed,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.xSmall,
            AppSpacing.medium,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: flushing ? null : cubit.flush,
                icon: flushing
                    ? const SizedBox.square(
                        dimension: AppIconSize.small,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(flushing ? 'Sending…' : 'Flush now'),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              OutlinedButton.icon(
                onPressed: queue.failed == 0 ? null : cubit.retryFailed,
                icon: const Icon(Icons.replay),
                label: const Text('Retry failed'),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              OutlinedButton.icon(
                onPressed: cubit.trackBurst,
                icon: const Icon(Icons.bolt),
                label: const Text('Track ${DashboardCubit.burst} events'),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Events are stored first and wait here. The SDK sends them '
                'by itself (every 30 s, on a full batch, on reconnect); '
                'Flush now sends them at once.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
