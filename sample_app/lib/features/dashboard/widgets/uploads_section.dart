import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/common/time_text.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/queue_stats.dart';
import 'package:tracklite_sample/domain/network/device_network.dart';
import 'package:tracklite_sample/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_words.dart';

/// The last upload, the next retry, and the network with its demo switch.
class UploadsSection extends StatelessWidget {
  const UploadsSection({super.key, required this.queue, this.network});

  final QueueStats queue;
  final NetworkStatus? network;

  @override
  Widget build(BuildContext context) {
    final last = queue.lastUpload;
    final nextRetry = queue.nextRetryAt;
    final network = this.network;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Uploads'),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Last upload'),
          subtitle: Text(
            last == null
                ? 'None yet'
                : '${triggerWords(last.trigger)} · '
                      '${outcomeWords(last.outcome)}'
                      '${last.events == 0 ? '' : ', ${count(last.events, 'event')}'}'
                      ' · ${clockTime(last.finishedAt)}',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('Next retry'),
          subtitle: Text(
            nextRetry == null
                ? 'No event is waiting for a retry'
                : 'At ${clockTime(nextRetry)} (backoff after a server error)',
          ),
        ),
        if (network != null) ...[
          _NetworkRow(network),
          SwitchListTile.adaptive(
            title: const Text('Device offline'),
            subtitle: const Text(
              'For the demo: the SDK sees no network, stores events and '
              'waits. Switch it off to see the reconnect send them.',
            ),
            value: network.simulatingOffline,
            onChanged: context.read<DashboardCubit>().simulateOffline,
          ),
        ],
      ],
    );
  }
}

class _NetworkRow extends StatelessWidget {
  const _NetworkRow(this.network);

  final NetworkStatus network;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, label, color) = switch (network) {
      NetworkStatus(online: true) => (Icons.wifi, 'Online', colors.sent),
      NetworkStatus(simulatingOffline: true) => (
        Icons.wifi_off,
        'Offline (simulated)',
        colors.offline,
      ),
      _ => (Icons.wifi_off, 'Offline: no connection', colors.offline),
    };
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
    );
  }
}
