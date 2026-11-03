import 'package:meta/meta.dart';
import 'package:tracklite/src/client/tracklite_client.dart';
import 'package:tracklite/src/config/tracklite_config.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';

/// The client behind the interface. Phase 1 logs each call; the queue
/// (Phase 2) and the uploads (Phase 3) fill it in.
@internal
final class TrackLiteClientImpl implements TrackLiteClient {
  TrackLiteClientImpl({required this.config, required this.logger});

  final TrackLiteConfig config;
  final TrackLiteLogger logger;

  String? _userId;
  bool _closed = false;

  /// The user id attached to new events (Phase 2 stores it).
  String? get userId => _userId;

  bool get isClosed => _closed;

  @override
  void track(String name, {Map<String, Object> properties = const {}}) =>
      _guard('track', () {
        if (_ignoredAfterShutdown('track("$name")')) return;
        logger.debug('track("$name", $properties) for ${_userId ?? 'anon'}');
      });

  @override
  void setUserId(String userId) => _guard('setUserId', () {
    if (_ignoredAfterShutdown('setUserId')) return;
    _userId = userId;
    logger.debug('setUserId("$userId")');
  });

  @override
  void clearUser() => _guard('clearUser', () {
    if (_ignoredAfterShutdown('clearUser')) return;
    _userId = null;
    logger.debug('clearUser()');
  });

  @override
  Future<FlushResult> flush() async {
    if (_closed) return const NotInitialized();
    // Nothing is stored yet (Phase 2), so there is never anything to send.
    return const NothingToSend();
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    logger.debug('shutdown()');
  }

  bool _ignoredAfterShutdown(String call) {
    if (!_closed) return false;
    logger.warning('$call after shutdown(): ignored');
    return true;
  }

  /// Runs a host-facing call so that nothing it throws reaches the host: an
  /// analytics SDK that crashes the app it measures is worse than none. The
  /// failure is logged (in debug mode) instead.
  void _guard(String call, void Function() body) {
    try {
      body();
    } on Object catch (error, stackTrace) {
      logger.error('$call failed', error, stackTrace);
    }
  }
}
