import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';

/// The Profile tab. Phase 5 signs a user in and out (`setUserId`,
/// `clearUser`) and shows the anonymous id.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const EmptyStateView(
        icon: Icons.badge_outlined,
        title: 'Signed out',
        message:
            'Signing in ties your events to a user id. It arrives with '
            'the SDK tools.',
      ),
    );
  }
}
