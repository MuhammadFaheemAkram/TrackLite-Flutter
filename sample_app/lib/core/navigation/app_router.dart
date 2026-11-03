import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/core/navigation/app_routes.dart';

/// Creates the app's [GoRouter].
///
/// A factory rather than a global: the app widget owns one router for its
/// lifetime, and every widget test starts from a fresh one.
GoRouter createAppRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? const HomeRoute().location,
    routes: $appRoutes,
    errorBuilder: (context, state) =>
        _NotFoundPage(location: state.uri.toString()),
  );
}

/// Shown when a location matches no route, e.g. a mistyped deep link.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: EmptyStateView(
        icon: Icons.link_off,
        title: 'Page not found',
        message: 'Nothing lives at "$location".',
        action: FilledButton.tonal(
          onPressed: () => const HomeRoute().go(context),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}
