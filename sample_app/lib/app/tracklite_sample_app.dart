import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/core/navigation/app_router.dart';

/// The root widget: themes and the router.
///
/// This `State` owns the router and disposes it. The router is created once,
/// not in `build`: a new router on every rebuild would reset navigation.
/// The theme follows the system: the sample has no settings screen.
class TrackLiteSampleApp extends StatefulWidget {
  const TrackLiteSampleApp({super.key, this.initialLocation});

  /// Lets tests start on a deep link. The app itself starts on Home.
  final String? initialLocation;

  @override
  State<TrackLiteSampleApp> createState() => _TrackLiteSampleAppState();
}

class _TrackLiteSampleAppState extends State<TrackLiteSampleApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackLite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
