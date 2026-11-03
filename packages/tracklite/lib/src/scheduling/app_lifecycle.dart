import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Whether the host app is in the foreground, and when that changes.
@internal
abstract interface class AppLifecycle {
  bool get isForeground;

  /// Every change: `true` when the app comes back, `false` when it goes to
  /// the background.
  Stream<bool> watchForeground();

  void dispose();
}

/// The app's lifecycle from Flutter's `AppLifecycleListener`. It needs the
/// widgets binding, which every Flutter app has by `initialize` (the README
/// says to call `WidgetsFlutterBinding.ensureInitialized()` first).
@internal
final class FlutterAppLifecycle implements AppLifecycle {
  FlutterAppLifecycle() {
    _listener = AppLifecycleListener(
      onResume: () => _set(true),
      // Paused is the last state before the OS may stop or kill the app.
      onPause: () => _set(false),
    );
  }

  late final AppLifecycleListener _listener;
  final _changes = StreamController<bool>.broadcast();
  bool _foreground = true;

  @override
  bool get isForeground => _foreground;

  void _set(bool foreground) {
    if (foreground == _foreground) return;
    _foreground = foreground;
    _changes.add(foreground);
  }

  @override
  Stream<bool> watchForeground() => _changes.stream;

  @override
  void dispose() {
    _listener.dispose();
    unawaited(_changes.close());
  }
}

/// An app that is always in the foreground: what the SDK assumes when it
/// can't follow the real lifecycle.
@internal
final class ForegroundOnly implements AppLifecycle {
  const ForegroundOnly();

  @override
  bool get isForeground => true;

  @override
  Stream<bool> watchForeground() => const Stream.empty();

  @override
  void dispose() {}
}

/// How the client gets the app's lifecycle: Flutter's, or (before the
/// widgets binding exists, which a host should have set up) always in the
/// foreground, with a warning. `initialize` never throws over it: only the
/// "paused" trigger is lost, and the background task still runs.
@internal
AppLifecycle Function(void Function(String warning) warn) createAppLifecycle =
    (warn) {
      try {
        return FlutterAppLifecycle();
      } on Object {
        warn(
          'no widgets binding yet: call WidgetsFlutterBinding.'
          'ensureInitialized() before initialize(). Assuming the foreground.',
        );
        return const ForegroundOnly();
      }
    };
