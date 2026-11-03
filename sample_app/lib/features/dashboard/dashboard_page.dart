import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';

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
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => switch (state.queue) {
          null => const LoadingView(message: 'Reading the queue…'),
          final queue => _QueueView(queue),
        },
      ),
    );
  }
}

class _QueueView extends StatelessWidget {
  const _QueueView(this.queue);

  final QueueStats queue;

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
          label: 'Sent',
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: Text(
            'Events are stored first and wait here. Uploading them arrives '
            'with the pipeline.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
