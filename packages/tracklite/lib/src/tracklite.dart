import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:tracklite/src/client/tracklite_client.dart';
import 'package:tracklite/src/client/tracklite_client_impl.dart';
import 'package:tracklite/src/config/tracklite_config.dart';
import 'package:tracklite/src/debug/tracklite_debug.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:tracklite/src/version.dart';

/// The SDK's front door: static calls, so any file can track an event
/// without passing anything around.
///
/// ```dart
/// await TrackLite.initialize(const TrackLiteConfig(apiKey: 'demo_key'));
/// TrackLite.track('purchase', properties: {'price': 20, 'currency': 'USD'});
/// ```
///
/// Every call forwards to one [TrackLiteClient] ([instance]). Calls made
/// before [initialize] finishes are kept (up to [earlyCallLimit] events) and
/// replayed in order, with the time they were made, once the SDK has
/// started. After [shutdown], calls are ignored and [flush] reports
/// [NotInitialized]. The SDK never throws at the app, except for a bad
/// configuration at [initialize].
abstract final class TrackLite {
  /// This SDK's version, sent with every upload so the server knows which
  /// client produced an event.
  static const String version = trackLiteVersion;

  /// How many events tracked before [initialize] finishes are kept; past
  /// it, the oldest are dropped (and counted once the SDK starts).
  static const int earlyCallLimit = 100;

  static TrackLiteClientImpl? _client;
  static Future<TrackLiteClientImpl>? _starting;
  static TrackLiteLogger _logger = TrackLiteLogger.silent();

  // Calls made before the SDK started, in order. They are kept only until
  // the first `shutdown`: after it, calls are ignored until the next
  // `initialize`.
  static final Queue<_EarlyCall> _early = Queue();
  static int _earlyTracks = 0;
  static int _earlyDropped = 0;
  static bool _keepEarlyCalls = true;

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
    _keepEarlyCalls = true;
    // A call while a start is in flight joins it: one client, built from
    // the first caller's config.
    if (_starting case final starting?) {
      await starting;
      return;
    }
    // Checked here, before the start exists. Inside `_start` it would throw
    // before the start's first `await`, while `_start` was still running
    // synchronously: its `finally` would clear `_starting` *before* the
    // failed start was stored in it, and every later call would join that
    // failure.
    config.validate();
    await (_starting = _start(config));
  }

  static Future<TrackLiteClientImpl> _start(TrackLiteConfig config) async {
    try {
      final client = await TrackLiteClientImpl.open(config);
      // Set before the shared future completes, so whoever awaited it
      // (another initialize, or a shutdown) finds the client in place.
      _client = client;
      _logger = client.logger;
      _replayEarlyCalls(client);
      return client;
    } finally {
      _starting = null;
    }
  }

  /// Records an event named [name] with its [properties], and returns at
  /// once. Values are `String`, finite `num` or `bool`.
  static void track(String name, {Map<String, Object> properties = const {}}) {
    if (_client case final client?) {
      return client.track(name, properties: properties);
    }
    // Stamped now, not when it is replayed: the event happened now.
    final at = clock.now();
    _keepEarly(_EarlyTrack((c) => c.trackAt(name, properties, at)));
  }

  /// Attaches [userId] to the events tracked from now on.
  static void setUserId(String userId) {
    if (_client case final client?) return client.setUserId(userId);
    _keepEarly(_EarlyCall((c) => c.setUserId(userId)));
  }

  /// Stops attaching a user id (for example when the user signs out), and
  /// starts a new anonymous id.
  static void clearUser() {
    if (_client case final client?) return client.clearUser();
    _keepEarly(_EarlyCall((c) => c.clearUser()));
  }

  /// Stores every event tracked so far, uploads the pending ones, and says
  /// what happened.
  static Future<FlushResult> flush() async =>
      await _client?.flush() ?? const NotInitialized();

  /// Stores what was tracked, then stops the SDK. Calls are ignored until
  /// the next [initialize]; stored events wait for it.
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
    _keepEarlyCalls = false;
    _early.clear();
    _earlyTracks = 0;
    _earlyDropped = 0;
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

  /// The running client's debug tools ([TrackLiteClient.debug]).
  ///
  /// Throws a [StateError] before [initialize], like [instance].
  static TrackLiteDebug get debug => instance.debug;

  static void _keepEarly(_EarlyCall call) {
    if (!_keepEarlyCalls) return;
    _early.add(call);
    if (call is! _EarlyTrack) return;
    // Bounded: an app that never calls initialize must not grow this list
    // forever. The oldest event goes; identity calls are always kept, so
    // the replayed events still get the right user.
    if (++_earlyTracks > earlyCallLimit) {
      final oldest = _early.firstWhere((early) => early is _EarlyTrack);
      _early.remove(oldest);
      _earlyTracks--;
      _earlyDropped++;
    }
  }

  static void _replayEarlyCalls(TrackLiteClientImpl client) {
    final replayed = _early.length;
    for (final call in _early) {
      call.replay(client);
    }
    client.countDropped(_earlyDropped);
    if (replayed > 0) {
      client.logger.debug(
        'replayed $replayed calls made before initialize() '
        '($_earlyDropped events dropped: the buffer was full)',
      );
    }
    _early.clear();
    _earlyTracks = 0;
    _earlyDropped = 0;
  }
}

/// A call made before the SDK started, replayed on the client once it has.
class _EarlyCall {
  _EarlyCall(this.replay);

  final void Function(TrackLiteClientImpl client) replay;
}

/// An early `track`: the kind the buffer's limit counts and drops.
final class _EarlyTrack extends _EarlyCall {
  _EarlyTrack(super.replay);
}
