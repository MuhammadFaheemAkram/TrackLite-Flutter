import 'package:clock/clock.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:tracklite/tracklite.dart';

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

/// A client on an in-memory database, with a fixed clock and readable ids.
Future<TrackLiteClientImpl> openTestClient({
  TrackLiteConfig config = const TrackLiteConfig(
    apiKey: 'demo_key',
    debugMode: true,
  ),
  TrackLiteDatabase? database,
  int? maxQueue,
  LogRecorder? logs,
  Clock? clock,
  String Function()? newId,
}) => TrackLiteClientImpl.open(
  maxQueue == null
      ? config
      : TrackLiteConfig(
          apiKey: config.apiKey,
          batchSize: 1,
          maxQueueSize: maxQueue,
          debugMode: config.debugMode,
        ),
  database: database ?? TrackLiteDatabase.inMemory(),
  logger: (logs ?? LogRecorder()).logger(enabled: config.debugMode),
  clock: clock ?? Clock.fixed(testNow),
  newId: newId ?? SequentialIds().call,
);
