import 'package:flutter/widgets.dart';
import 'package:tracklite/src/client/tracklite_client.dart';
import 'package:tracklite/src/tracklite.dart';

/// Tracks `screen_opened {screen: <route name>}` as the app navigates.
///
/// Add it to a navigator's observers (`MaterialApp.navigatorObservers`, or a
/// go_router route's `observers`). It tracks a **named page route** each
/// time one becomes visible: pushed, returned to by a pop, or replacing
/// another. Dialogs and popups aren't screens, and unnamed routes are
/// skipped.
///
/// **A navigator's first route is skipped:** it is the screen a container
/// (a tab, the app itself) shows, and the container knows when it is shown;
/// switching back to an open tab, for one, is no navigation at all. Track
/// those where they are shown.
///
/// Only the route's **name** is sent, never its arguments or path: those
/// can carry ids and personal data.
class TrackLiteNavigatorObserver extends NavigatorObserver {
  /// An observer that tracks through [_client], or through the `TrackLite`
  /// facade by default. [screenName] picks the name to send (the route's
  /// own by default); returning `null` skips the route.
  TrackLiteNavigatorObserver({
    this._client,
    String? Function(Route<Object?> route)? screenName,
  }) : _screenName = screenName ?? _routeName;

  final TrackLiteClient? _client;
  final String? Function(Route<Object?> route) _screenName;

  static String? _routeName(Route<Object?> route) => route.settings.name;

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    if (previousRoute == null) return; // the navigator's first route
    _shown(route);
  }

  @override
  void didPop(Route<Object?> route, Route<Object?>? previousRoute) {
    if (previousRoute != null) _shown(previousRoute);
  }

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) {
    if (newRoute != null) _shown(newRoute);
  }

  void _shown(Route<Object?> route) {
    if (route is! PageRoute<Object?>) return;
    final name = _screenName(route);
    if (name == null || name.isEmpty) return;
    final properties = {'screen': name};
    if (_client case final client?) {
      client.track('screen_opened', properties: properties);
    } else {
      TrackLite.track('screen_opened', properties: properties);
    }
  }
}
