// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$mainShellRoute];

RouteBase get $mainShellRoute => StatefulShellRouteData.$route(
  factory: $MainShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      navigatorKey: HomeBranch.$navigatorKey,
      observers: HomeBranch.$observers,
      routes: [
        GoRouteData.$route(
          path: '/home',
          name: 'home',
          hasOverriddenOnExit: false,
          factory: $HomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: ShopBranch.$navigatorKey,
      observers: ShopBranch.$observers,
      routes: [
        GoRouteData.$route(
          path: '/shop',
          name: 'shop',
          hasOverriddenOnExit: false,
          factory: $ShopRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':productId',
              name: 'product',
              hasOverriddenOnExit: false,
              factory: $ProductRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: ProfileBranch.$navigatorKey,
      observers: ProfileBranch.$observers,
      routes: [
        GoRouteData.$route(
          path: '/profile',
          name: 'profile',
          hasOverriddenOnExit: false,
          factory: $ProfileRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: DashboardBranch.$navigatorKey,
      observers: DashboardBranch.$observers,
      routes: [
        GoRouteData.$route(
          path: '/dashboard',
          name: 'dashboard',
          hasOverriddenOnExit: false,
          factory: $DashboardRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ShopRoute on GoRouteData {
  static ShopRoute _fromState(GoRouterState state) => const ShopRoute();

  @override
  String get location => GoRouteData.$location('/shop');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProductRoute on GoRouteData {
  static ProductRoute _fromState(GoRouterState state) =>
      ProductRoute(productId: state.pathParameters['productId']!);

  ProductRoute get _self => this as ProductRoute;

  @override
  String get location =>
      GoRouteData.$location('/shop/${Uri.encodeComponent(_self.productId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) =>
      const DashboardRoute();

  @override
  String get location => GoRouteData.$location('/dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
