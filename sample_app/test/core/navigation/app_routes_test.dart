import 'package:flutter_test/flutter_test.dart';
import 'package:tracklite_sample/core/navigation/app_routes.dart';
import 'package:tracklite_sample/features/shell/main_shell.dart';

void main() {
  test('every destination has its typed location', () {
    expect(const HomeRoute().location, '/home');
    expect(const ShopRoute().location, '/shop');
    expect(const ProductRoute(productId: 'grinder').location, '/shop/grinder');
    expect(const ProfileRoute().location, '/profile');
    expect(const DashboardRoute().location, '/dashboard');
  });

  test('ids are encoded into their locations', () {
    expect(const ProductRoute(productId: 'a/b c').location, '/shop/a%2Fb%20c');
  });

  test("the tabs are in the shell branches' order", () {
    expect(AppTab.values.map((tab) => tab.label), [
      'Home',
      'Shop',
      'Profile',
      'Dashboard',
    ]);
  });
}
