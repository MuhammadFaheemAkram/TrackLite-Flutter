import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';

/// The Dashboard tab: the SDK's live state. Phase 2 shows the queue; the
/// full dashboard (uploads, retries, demo controls) grows from there.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const EmptyStateView(
        icon: Icons.insights_outlined,
        title: 'Nothing stored yet',
        message:
            'The SDK logs each call for now. Its event queue arrives '
            'next, and shows here.',
      ),
    );
  }
}
