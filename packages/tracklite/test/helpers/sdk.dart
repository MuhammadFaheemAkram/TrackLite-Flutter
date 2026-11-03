import 'package:clock/clock.dart';
import 'package:tracklite/src/background/background_uploads.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/scheduling/app_lifecycle.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:tracklite/testing.dart';
import 'package:tracklite/tracklite.dart';

import 'fakes.dart';

/// 09:41 UTC on the day the tests were written: a fixed "now".
final testNow = DateTime.utc(2026, 11, 3, 9, 41);

/// Ids in order, `id-1`, `id-2`, …, so a test can name the event it means.
class SequentialIds {
  int _next = 1;

  String call() => 'id-${_next++}';
}

/// Every line a logger was asked to write, with its level.
class LogRecorder {
  final List<(LogLevel, String)> lines = [];

  TrackLiteLogger logger({bool enabled = true}) => TrackLiteLogger(
    enabled: enabled,
    sink: (level, message, {error, stackTrace}) =>
        lines.add((level, error == null ? message : '$message: $error')),
  );

  Iterable<String> at(LogLevel level) =>
      lines.where((line) => line.$1 == level).map((line) => line.$2);
}

/// A fake server that answers at once and never fails: tests choose
/// failures on purpose (a [ScriptedTransport], or the server's knobs).
FakeAnalyticsServer instantServer() =>
    FakeAnalyticsServer(latency: Duration.zero, failureRate: 0);

/// A config for tests: debug logs on, an [instantServer], a monitor the
/// test controls, and no background scheduling (no plugin in a test).
TrackLiteConfig testConfig({
  AnalyticsTransport? transport,
  NetworkMonitor? networkMonitor,
  int batchSize = 20,
  int maxQueueSize = 10000,
  int maxRetries = 5,
  Duration flushInterval = const Duration(seconds: 30),
  bool debugMode = true,
}) => TrackLiteConfig(
  apiKey: 'demo_key',
  batchSize: batchSize,
  flushInterval: flushInterval,
  maxRetries: maxRetries,
  maxQueueSize: maxQueueSize,
  backgroundUploads: false,
  debugMode: debugMode,
  transport: transport ?? instantServer(),
  networkMonitor: networkMonitor ?? FakeNetworkMonitor(),
);

/// A client on an in-memory database, with a fixed clock and readable ids.
Future<TrackLiteClientImpl> openTestClient({
  TrackLiteConfig? config,
  TrackLiteDatabase? database,
  int? maxQueue,
  LogRecorder? logs,
  Clock? clock,
  String Function()? newId,
  AppLifecycle? lifecycle,
  BackgroundUploads? background,
}) => TrackLiteClientImpl.open(
  config ?? testConfig(batchSize: 1, maxQueueSize: maxQueue ?? 10000),
  database: database ?? TrackLiteDatabase.inMemory(),
  logger: (logs ?? LogRecorder()).logger(enabled: config?.debugMode ?? true),
  clock: clock ?? Clock.fixed(testNow),
  newId: newId ?? SequentialIds().call,
  lifecycle: lifecycle ?? FakeAppLifecycle(),
  background: background ?? FakeBackgroundUploads(),
);
