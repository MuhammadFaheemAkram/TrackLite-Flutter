import 'dart:developer' as developer;

import 'package:meta/meta.dart';

/// How serious a log line is.
@internal
enum LogLevel { debug, warning, error }

/// Where log lines go: `dart:developer`'s log by default (DevTools and the
/// IDE's console show it under "TrackLite"), a list in tests.
@internal
typedef LogSink = void Function(
  LogLevel level,
  String message, {
  Object? error,
  StackTrace? stackTrace,
});

/// The SDK's only way of talking to developers.
///
/// Silent unless the app turned on `debugMode`: an SDK must never fill a
/// host app's logs in production. In debug mode it explains what happened
/// to each call, including the ones it ignored or rejected, because the
/// SDK never throws at runtime and a log line is the only trace.
@internal
final class TrackLiteLogger {
  TrackLiteLogger({required this.enabled, LogSink? sink})
    : _sink = sink ?? _developerLog;

  /// A logger that never logs (before `initialize` has a config).
  TrackLiteLogger.silent() : this(enabled: false);

  final bool enabled;
  final LogSink _sink;

  void debug(String message) => _log(LogLevel.debug, message);

  void warning(String message) => _log(LogLevel.warning, message);

  void error(String message, Object error, StackTrace stackTrace) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (enabled) {
      _sink(level, message, error: error, stackTrace: stackTrace);
    }
  }

  static void _developerLog(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'TrackLite',
      // The `logging` package's levels: FINE, WARNING, SEVERE.
      level: switch (level) {
        LogLevel.debug => 500,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }
}
