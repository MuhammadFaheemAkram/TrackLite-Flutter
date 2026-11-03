import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/features/home/cubit/home_cubit.dart';
import 'package:tracklite_sample/features/home/cubit/home_state.dart';

/// The Home tab: a few buttons that each track an event.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final lastTapped = state.lastTapped;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Text(
                  'Each button tracks an event with the TrackLite SDK. '
                  'The Dashboard shows where it goes.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SectionHeader('Buttons'),
              for (final button in HomeButton.values)
                ListTile(
                  leading: Icon(button.icon),
                  title: Text(button.label),
                  subtitle: Text('Sends button_clicked, button: ${button.id}'),
                  onTap: () => context.read<HomeCubit>().tapped(button),
                ),
              if (lastTapped != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      'Tracked button_clicked (${lastTapped.id}). '
                      '${state.taps} so far.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

extension on HomeButton {
  IconData get icon => switch (this) {
    HomeButton.getStarted => Icons.rocket_launch_outlined,
    HomeButton.share => Icons.share_outlined,
    HomeButton.rate => Icons.star_outline,
  };
}
