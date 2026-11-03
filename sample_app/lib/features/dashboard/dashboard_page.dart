import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:tracklite_sample/features/dashboard/flush_words.dart';

/// The Dashboard tab: the SDK's live state. Phase 2 shows the queue and
/// the identity; uploads, retries and the demo controls come later.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..start(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listenWhen: (before, after) => after.flushSerial != before.flushSerial,
        listener: (context, state) {
          final outcome = state.lastFlush;
          if (outcome == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(flushWords(outcome))));
        },
        builder: (context, state) => switch (state.queue) {
          null => const LoadingView(message: 'Reading the queue…'),
          final queue => _QueueView(queue, flushing: state.flushing),
        },
      ),
    );
  }
}

class _QueueView extends StatelessWidget {
  const _QueueView(this.queue, {required this.flushing});

  final QueueStats queue;
  final bool flushing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      children: [
        const SectionHeader('Queue'),
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
                onPressed: flushing
                    ? null
                    : context.read<DashboardCubit>().flush,
                icon: flushing
                    ? const SizedBox.square(
                        dimension: AppIconSize.small,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(flushing ? 'Sending…' : 'Flush now'),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Events are stored first and wait here. Flush now sends them '
                'to the fake server, which takes a moment and fails about '
                '1 request in 10.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
