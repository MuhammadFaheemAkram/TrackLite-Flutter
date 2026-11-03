import 'dart:async';

import 'package:tracklite/src/background/background_uploads.dart';
import 'package:tracklite/src/scheduling/app_lifecycle.dart';

/// An app lifecycle a test moves by hand.
class FakeAppLifecycle implements AppLifecycle {
  final _changes = StreamController<bool>.broadcast();
  bool _foreground = true;
  bool disposed = false;

  @override
  bool get isForeground => _foreground;

  set foreground(bool value) {
    if (value == _foreground) return;
    _foreground = value;
    _changes.add(value);
  }

  @override
  Stream<bool> watchForeground() => _changes.stream;

  @override
  void dispose() => disposed = true;
}

/// Background scheduling that only records what it was asked.
class FakeBackgroundUploads implements BackgroundUploads {
  final calls = <String>[];
  Object? error;

  @override
  Future<void> enable() async {
    calls.add('enable');
    if (error case final error?) throw error;
  }

  @override
  Future<void> disable() async {
    calls.add('disable');
    if (error case final error?) throw error;
  }
}
