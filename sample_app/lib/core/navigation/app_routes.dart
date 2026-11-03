import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tracklite/tracklite.dart';
import 'package:tracklite_sample/di/injection.dart';
import 'package:tracklite_sample/domain/analytics/analytics_service.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_page.dart';
import 'package:tracklite_sample/features/home/home_page.dart';
import 'package:tracklite_sample/features/product/product_page.dart';
import 'package:tracklite_sample/features/profile/profile_page.dart';
import 'package:tracklite_sample/features/shell/main_shell.dart';
import 'package:tracklite_sample/features/shop/shop_page.dart';

part 'app_routes.g.dart';

// Typed routes: every destination is a class, and `go_router_builder`
// generates its path parsing, `location` getter and `go`/`push` helpers. A
// typo or a missing parameter is a compile error instead of a runtime "page
// not found".
//
// Four tabs: Home, Shop (with a product pushed inside the tab), Profile and
// Dashboard. A product is a child of Shop, so a link to one opens with the
// shop underneath, and Back always has somewhere to go.

/// `StatefulShellRoute` gives every tab its own Navigator and keeps inactive
/// tabs alive in an IndexedStack, so switching tabs preserves each tab's
/// state (a product open in Shop, the dashboard's scroll position).
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: '/home', name: 'home')],
    ),
    TypedStatefulShellBranch<ShopBranch>(
      routes: [
        TypedGoRoute<ShopRoute>(
          path: '/shop',
          name: 'shop',
          routes: [
            TypedGoRoute<ProductRoute>(path: ':productId', name: 'product'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile', name: 'profile')],
    ),
    TypedStatefulShellBranch<DashboardBranch>(
      routes: [
        TypedGoRoute<DashboardRoute>(path: '/dashboard', name: 'dashboard'),
      ],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainShell(
      navigationShell: navigationShell,
      onTabShown: (tab) => getIt<AnalyticsService>().track(
        'screen_opened',
        properties: {'screen': tab.name},
      ),
    );
  }
}

// A named navigator key per tab makes each back stack addressable (and
// readable in debugging tools). Each tab's navigator also has the SDK's
// observer: it tracks the named screens pushed inside a tab (a product),
// and Back to the one under it. A tab's first screen is the shell's to
// report.

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'homeTab');

  static final List<NavigatorObserver> $observers = [
    TrackLiteNavigatorObserver(),
  ];
}

class ShopBranch extends StatefulShellBranchData {
  const ShopBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shopTab');

  static final List<NavigatorObserver> $observers = [
    TrackLiteNavigatorObserver(),
  ];
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profileTab');

  static final List<NavigatorObserver> $observers = [
    TrackLiteNavigatorObserver(),
  ];
}

class DashboardBranch extends StatefulShellBranchData {
  const DashboardBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'dashboardTab');

  static final List<NavigatorObserver> $observers = [
    TrackLiteNavigatorObserver(),
  ];
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

class ShopRoute extends GoRouteData with $ShopRoute {
  const ShopRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ShopPage();
}

/// `/shop/:productId`: one product, above the shop in the Shop tab.
class ProductRoute extends GoRouteData with $ProductRoute {
  const ProductRoute({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProductPage(productId: productId);
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfilePage();
}

class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DashboardPage();
}
