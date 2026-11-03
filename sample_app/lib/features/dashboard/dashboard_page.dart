import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_state.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_words.dart';
import 'package:tracklite_sample/features/dashboard/widgets/demo_server_section.dart';
import 'package:tracklite_sample/features/dashboard/widgets/event_lists.dart';
import 'package:tracklite_sample/features/dashboard/widgets/queue_section.dart';
import 'package:tracklite_sample/features/dashboard/widgets/totals_section.dart';
import 'package:tracklite_sample/features/dashboard/widgets/uploads_section.dart';

/// The Dashboard tab: the SDK's live state, and the demo's controls.
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
        listenWhen: (before, after) =>
            after.effectSerial != before.effectSerial,
        listener: (context, state) {
          final effect = state.effect;
          if (effect == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(effectWords(effect))));
        },
        builder: (context, state) {
          final queue = state.queue;
          if (queue == null) {
            return const LoadingView(message: 'Reading the queue…');
          }
          final server = state.server;
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.large),
            children: [
              QueueSection(queue: queue, flushing: state.flushing),
              UploadsSection(queue: queue, network: state.network),
              if (server != null) DemoServerSection(server: server),
              TotalsSection(queue: queue),
              RecentEventsSection(events: state.recentEvents),
              UploadLogSection(runs: state.uploads),
            ],
          );
        },
      ),
    );
  }
}
