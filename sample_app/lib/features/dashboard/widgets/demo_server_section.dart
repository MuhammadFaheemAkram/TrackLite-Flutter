import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/demo/demo_backend.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';

/// The fake server's knobs and what it has received: the demo's way to see
/// retries (raise the failures) and batching in flight (slow it down).
class DemoServerSection extends StatelessWidget {
  const DemoServerSection({super.key, required this.server});

  final DemoServerState server;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<DashboardCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Demo server'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Failures', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xSmall),
              SegmentedChoice<ServerFailures>(
                values: ServerFailures.values,
                labelOf: (f) => f.label,
                selected: server.failures,
                onSelected: cubit.setServerFailures,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text('Speed', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xSmall),
              SegmentedChoice<ServerSpeed>(
                values: ServerSpeed.values,
                labelOf: (s) => s.label,
                selected: server.speed,
                onSelected: cubit.setServerSpeed,
              ),
            ],
          ),
        ),
        StatRow(
          icon: Icons.call_received,
          label: 'Requests received',
          value: '${server.requests}',
        ),
        StatRow(
          icon: Icons.inventory_2_outlined,
          label: 'Events stored',
          value: '${server.accepted}',
        ),
        StatRow(
          icon: Icons.content_copy_outlined,
          label: 'Duplicates dropped',
          value: '${server.duplicates}',
        ),
        StatRow(
          icon: Icons.report_outlined,
          label: 'Requests failed',
          value: '${server.serverFailures}',
        ),
      ],
    );
  }
}
