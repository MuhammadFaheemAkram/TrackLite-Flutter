import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The tabs, in the order of the shell's branches.
enum AppTab {
  home('Home', Icons.home_outlined, Icons.home),
  shop('Shop', Icons.storefront_outlined, Icons.storefront),
  profile('Profile', Icons.person_outline, Icons.person),
  dashboard('Dashboard', Icons.insights_outlined, Icons.insights);

  const AppTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Hosts the bottom [NavigationBar] around the active tab.
///
/// [navigationShell] holds the tab navigators in an IndexedStack; this widget
/// only decides which branch is visible. Each tab screen brings its own
/// `Scaffold` and `AppBar`.
///
/// It also says when a tab's screen is shown ([onTabShown]: at start and on
/// every tap of the bar). Switching back to an open tab is no navigation at
/// all, so no navigator observer could see it; screens pushed *inside* a tab
/// are the SDK's navigator observer's.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
    required this.onTabShown,
  });

  final StatefulNavigationShell navigationShell;
  final void Function(AppTab tab) onTabShown;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    widget.onTabShown(AppTab.values[widget.navigationShell.currentIndex]);
  }

  // Tapping the tab that is already open returns it to its first screen
  // (Shop's list, from a product), as both platforms' tab bars do.
  void _selectTab(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    widget.onTabShown(AppTab.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      // The tab labels keep their size whatever the text setting, as the
      // platforms' own tab bars do. A long press shows the label in a
      // tooltip, and screen readers read it.
      bottomNavigationBar: MediaQuery.withNoTextScaling(
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _selectTab,
          destinations: [
            for (final tab in AppTab.values)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
                tooltip: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}
