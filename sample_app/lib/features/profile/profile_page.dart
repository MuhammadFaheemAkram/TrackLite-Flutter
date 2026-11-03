import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_cubit.dart';
import 'package:tracklite_sample/features/profile/cubit/profile_state.dart';

/// The Profile tab: sign in as a user id (`setUserId`), sign out
/// (`clearUser`), and the anonymous id.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..start(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => switch (state.identity) {
          null => const LoadingView(),
          final identity => _IdentityView(identity),
        },
      ),
    );
  }
}

class _IdentityView extends StatelessWidget {
  const _IdentityView(this.identity);

  final AnalyticsIdentity identity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final userId = identity.userId;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      children: [
        if (userId == null)
          const _SignInForm()
        else ...[
          const SectionHeader('Signed in'),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(userId),
            subtitle: const Text('Every event from now on carries this id.'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
            child: OutlinedButton.icon(
              onPressed: context.read<ProfileCubit>().signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
        ],
        const SectionHeader('Anonymous id'),
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: Text(identity.anonymousId),
          subtitle: Text(
            'This installation, without a user. Signing out starts a new '
            "one, so the next person on this phone isn't linked to you.",
            style: muted,
          ),
        ),
      ],
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  final _userId = TextEditingController();

  @override
  void dispose() {
    _userId.dispose();
    super.dispose();
  }

  void _signIn() {
    context.read<ProfileCubit>().signIn(_userId.text);
    _userId.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Signed out', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xSmall),
          const Text(
            'Signing in ties your events to a user id. There is no '
            'password: it only shows setUserId.',
          ),
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _userId,
            decoration: const InputDecoration(
              labelText: 'User id',
              hintText: 'user_123',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signIn(),
          ),
          const SizedBox(height: AppSpacing.small),
          ListenableBuilder(
            listenable: _userId,
            builder: (context, _) => FilledButton.icon(
              onPressed: _userId.text.trim().isEmpty ? null : _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Sign in'),
            ),
          ),
        ],
      ),
    );
  }
}
