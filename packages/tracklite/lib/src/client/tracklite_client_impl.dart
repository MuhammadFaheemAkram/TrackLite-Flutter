import 'package:clock/clock.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/client/tracklite_client.dart';
import 'package:tracklite/src/config/tracklite_config.dart';
import 'package:tracklite/src/debug/tracklite_debug.dart';
import 'package:tracklite/src/identity/identity_store.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/network/fake_analytics_server.dart';
import 'package:tracklite/src/recording/event_recorder.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/upload/upload_manager.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:uuid/uuid.dart';

/// The client behind the interface: it stores every event, and uploads
/// them in batches.
@internal
final class TrackLiteClientImpl implements TrackLiteClient {
  TrackLiteClientImpl._({
    required this.config,
    required this.logger,
    required this.database,
    required this._recorder,
    required this._identity,
    required this._uploads,
  });

  /// Opens the client's database and identity. [database], [clock] and
  /// [newId] are for tests; by default the database is the file on the
  /// device, the time is now and ids are UUID v4s.
  static Future<TrackLiteClientImpl> open(
    TrackLiteConfig config, {
    TrackLiteDatabase? database,
    TrackLiteLogger? logger,
    Clock? clock,
    String Function()? newId,
  }) async {
    final log = logger ?? TrackLiteLogger(enabled: config.debugMode);
    final ids = newId ?? const Uuid().v4;

    Future<TrackLiteClientImpl> start(TrackLiteDatabase database) async {
      final recorder = EventRecorder(
        database: database,
        maxQueueSize: config.maxQueueSize,
        logger: log,
        newId: ids,
        clock: clock,
      );
      final identity = await IdentityStore.load(
        meta: database.metaDao,
        recorder: recorder,
        newId: ids,
      );
      return TrackLiteClientImpl._(
        config: config,
        logger: log,
        database: database,
        recorder: recorder,
        identity: identity,
        uploads: UploadManager(
          database: database,
          recorder: recorder,
          transport: config.transport ?? FakeAnalyticsServer(),
          apiKey: config.apiKey,
          batchSize: config.batchSize,
          logger: log,
          newId: ids,
          clock: clock,
        ),
      );
    }

    final onDisk = database ?? openTrackLiteDatabase();
    try {
      return await start(onDisk);
    } on Object catch (error, stackTrace) {
      // The file can't be opened (no space, a corrupt file). Failing
      // `initialize` would take the host down with it; instead, this
      // session's events live in memory and are lost when the app quits.
      log.error(
        'opening the event database failed: events are kept in memory '
        'for this session',
        error,
        stackTrace,
      );
      try {
        await onDisk.close();
      } on Object {
        // Already broken; nothing more to release.
      }
      return start(TrackLiteDatabase.inMemory());
    }
  }

  final TrackLiteConfig config;
  final TrackLiteLogger logger;
  final TrackLiteDatabase database;
  final EventRecorder _recorder;
  final IdentityStore _identity;
  final UploadManager _uploads;

  bool _closed = false;

  /// The user id attached to new events.
  String? get userId => _identity.userId;

  /// The anonymous id attached to new events.
  String get anonymousId => _identity.anonymousId;

  bool get isClosed => _closed;

  /// Completes once every call so far is stored.
  Future<void> get idle => _recorder.idle;

  /// Whether nothing is waiting to be stored, right now.
  @visibleForTesting
  bool get isIdle => _recorder.isIdle;

  @override
  TrackLiteDebug get debug => DatabaseDebug(database);

  @override
  void track(String name, {Map<String, Object> properties = const {}}) =>
      trackAt(name, properties);

  /// [track], stamped [at] a given time: the facade replays calls made
  /// before the SDK had started with the time they were made.
  void trackAt(String name, Map<String, Object> properties, [DateTime? at]) =>
      _guard('track', () {
        if (_ignoredAfterShutdown('track("$name")')) return;
        _recorder.record(
          name,
          properties,
          userId: _identity.userId,
          anonymousId: _identity.anonymousId,
          at: at,
        );
      });

  @override
  void setUserId(String userId) => _guard('setUserId', () {
    if (_ignoredAfterShutdown('setUserId')) return;
    if (userId.trim().isEmpty || userId.length > maxUserIdLength) {
      logger.warning(
        'setUserId("$userId") ignored: a user id is 1–$maxUserIdLength '
        'characters',
      );
      return;
    }
    _identity.setUserId(userId);
    logger.debug('setUserId("$userId")');
  });

  @override
  void clearUser() => _guard('clearUser', () {
    if (_ignoredAfterShutdown('clearUser')) return;
    _identity.clear();
    logger.debug('clearUser(): new anonymous id ${_identity.anonymousId}');
  });

  /// Counts [count] calls dropped before the SDK started (the facade's
  /// buffer was full).
  void countDropped(int count) {
    if (count > 0) {
      _recorder.enqueue(AddToCounter(MetaKeys.droppedTotal, count));
    }
  }

  /// Whether an upload is running.
  bool get isUploading => _uploads.isUploading;

  @override
  Future<FlushResult> flush() async {
    if (_closed) return const NotInitialized();
    // An explicit flush sends everything waiting, retries included: the
    // developer asked for it now.
    final result = await _uploads.upload(
      UploadTrigger.manual,
      ignoreBackoff: true,
    );
    logger.debug('flush(): $result');
    return result;
  }

  @override
  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    // What was tracked before the shutdown is stored, a running upload
    // finishes, then the file closes.
    await _recorder.close();
    await _uploads.close();
    await database.close();
    logger.debug('shutdown()');
  }

  /// The longest user id the SDK accepts.
  static const maxUserIdLength = 255;

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
