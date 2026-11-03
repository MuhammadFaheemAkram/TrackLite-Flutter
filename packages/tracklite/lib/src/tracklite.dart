import 'package:tracklite/src/client/tracklite_client.dart';
import 'package:tracklite/src/config/tracklite_config.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';

/// The SDK's front door: static calls, so any file can track an event
/// without passing anything around.
///
/// ```dart
/// await TrackLite.initialize(const TrackLiteConfig(apiKey: 'demo_key'));
/// TrackLite.track('purchase', properties: {'price': 20, 'currency': 'USD'});
/// ```
///
/// Every call forwards to one [TrackLiteClient] ([instance]). Before
/// [initialize] finishes, and after [shutdown], calls are ignored and
/// [flush] reports [NotInitialized]: the SDK never throws at the app, except
/// for a bad configuration at [initialize].
abstract final class TrackLite {
  /// This SDK's version, sent with every upload so the server knows which
  /// client produced an event.
  static const String version = '0.1.0';

  static TrackLiteClient? _client;
  static Future<TrackLiteClient>? _starting;
  static TrackLiteLogger _logger = TrackLiteLogger.silent();

  /// Starts the SDK with [config]. Call it once, before `runApp`.
  ///
  /// Throws an [ArgumentError] if [config] breaks a rule. A second call
  /// while the SDK runs is ignored (with a warning in debug mode): to change
  /// the configuration, [shutdown] first. Two calls at once share one start.
  static Future<void> initialize(TrackLiteConfig config) async {
    if (_client != null) {
      _logger.warning(
        'initialize() while running: ignored. Call shutdown() '
        'first to change the configuration.',
      );
      return;
    }
    // A call while a start is in flight joins it: one client, built from
    // the first caller's config.
    await (_starting ??= _start(config));
  }

  static Future<TrackLiteClient> _start(TrackLiteConfig config) async {
    try {
      final client = await TrackLiteClient.create(config);
      // Set before the shared future completes, so whoever awaited it
      // (another initialize, or a shutdown) finds the client in place.
      _client = client;
      _logger = TrackLiteLogger(enabled: config.debugMode);
      return client;
    } finally {
      _starting = null;
    }
  }

  /// Records an event named [name] with its [properties], and returns at
  /// once. Values are `String`, finite `num` or `bool`.
  static void track(String name, {Map<String, Object> properties = const {}}) =>
      _client?.track(name, properties: properties);

  /// Attaches [userId] to the events tracked from now on.
  static void setUserId(String userId) => _client?.setUserId(userId);

  /// Stops attaching a user id, for example when the user signs out.
  static void clearUser() => _client?.clearUser();

  /// Uploads every pending event now, and says what happened.
  static Future<FlushResult> flush() async =>
      await _client?.flush() ?? const NotInitialized();

  /// Stops the SDK. Calls are ignored until the next [initialize]; stored
  /// events wait for it.
  static Future<void> shutdown() async {
    // A start in progress finishes first, so it can't come back to life
    // after the shutdown.
    if (_starting case final starting?) {
      try {
        await starting;
      } on Object {
        // It failed (a bad config, reported to its caller): nothing to stop.
      }
    }
    final client = _client;
    _client = null;
    _logger = TrackLiteLogger.silent();
    await client?.shutdown();
  }

  /// The running client, for apps that inject the SDK rather than call the
  /// facade (and for their tests, which pass a fake instead).
  ///
  /// Throws a [StateError] before [initialize]: asking for the client of an
  /// SDK that isn't running is a developer's mistake.
  static TrackLiteClient get instance =>
      _client ??
      (throw StateError(
        'TrackLite.instance before TrackLite.initialize() finished.',
      ));
}
