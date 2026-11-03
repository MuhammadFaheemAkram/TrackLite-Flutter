import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/model/flush_result.dart';
import 'package:tracklite/src/network/analytics_transport.dart';
import 'package:tracklite/src/recording/event_recorder.dart';
import 'package:tracklite/src/storage/event_mapper.dart';
import 'package:tracklite/src/storage/meta_keys.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/util/tracklite_logger.dart';
import 'package:tracklite/src/version.dart';

/// Why an upload ran; stored in the upload log.
@internal
enum UploadTrigger {
  manual,
  interval,
  threshold,
  paused,
  reconnect,
  retryDue,
  background,
}

/// Sends stored events to the server, in batches, oldest first.
///
/// One run at a time ([upload] while a run is going joins it). A run:
/// 1. waits for the recorder, so everything tracked so far is stored;
/// 2. puts back claims older than [claimTimeout] (an upload that died);
/// 3. claims a batch (`pending` → `sending`, one statement), sends it, and
///    on success marks it `sent` in one transaction with the total; then the
///    next batch, until none is due;
/// 4. stops at the first failure: a failing server isn't sent more;
/// 5. logs the run.
///
/// Delivery is **at least once**. If the app dies after the server stored a
/// batch but before `sent` is written, the claim expires and the batch is
/// sent again; the server keeps each event id once. Exactly once would need
/// the server and the device to commit together, which no network allows.
@internal
final class UploadManager {
  UploadManager({
    required this._database,
    required this._recorder,
    required this._transport,
    required this.apiKey,
    required this.batchSize,
    required this._logger,
    required this._newId,
    Clock? clock,
  }) : _clock = clock ?? const Clock();

  /// How long a claim may stay `sending` before it is assumed dead.
  static const claimTimeout = Duration(minutes: 5);

  /// How long `sent` events are kept for the debug tools.
  static const keepSent = Duration(hours: 24);

  final TrackLiteDatabase _database;
  final EventRecorder _recorder;
  final AnalyticsTransport _transport;
  final String apiKey;
  final int batchSize;
  final TrackLiteLogger _logger;
  final String Function() _newId;
  final Clock _clock;

  Future<FlushResult>? _running;

  /// Whether a run is going.
  bool get isUploading => _running != null;

  /// Runs an upload for [trigger], or joins the one already running.
  /// [ignoreBackoff] (an explicit flush) also sends events still waiting
  /// for a retry.
  Future<FlushResult> upload(
    UploadTrigger trigger, {
    bool ignoreBackoff = false,
  }) => _running ??= _run(trigger, ignoreBackoff).whenComplete(() {
    _running = null;
  });

  /// Completes once no run is going.
  Future<void> close() async {
    await _running;
  }

  DateTime _now() => _clock.now().toUtc();

  Future<FlushResult> _run(UploadTrigger trigger, bool ignoreBackoff) async {
    final startedAt = _now();
    var batches = 0;
    var sent = 0;
    FlushResult result;
    try {
      // Store first, then send. Today drift runs one statement at a time,
      // so the claim below would queue behind the recorder's write anyway;
      // this wait makes it a rule rather than an accident of the executor.
      await _recorder.idle;
      final released = await _database.eventDao.releaseExpiredClaims(
        startedAt.subtract(claimTimeout),
      );
      if (released > 0) {
        _logger.warning('$released events back to pending: their upload died');
      }
      result = await _sendBatches(
        ignoreBackoff: ignoreBackoff,
        onBatchSent: (count) {
          batches++;
          sent += count;
        },
      );
    } on Object catch (error, stackTrace) {
      // The database failed mid-run. Whatever was claimed stays `sending`
      // until its claim expires, then goes back to `pending`: nothing lost.
      _logger.error('upload failed', error, stackTrace);
      result = Failed(reason: 'storage error: $error', remaining: 0);
    }
    // Batches sent, then none left: that's an upload. (A run that sent some
    // batches and then failed still says it failed: events are waiting.)
    if (result is NothingToSend && batches > 0) {
      result = Uploaded(events: sent, batches: batches);
    }
    await _log(trigger, startedAt, result, batches: batches, events: sent);
    return result;
  }

  Future<FlushResult> _sendBatches({
    required bool ignoreBackoff,
    required void Function(int count) onBatchSent,
  }) async {
    final events = _database.eventDao;
    while (true) {
      final token = _newId();
      final claimed = await events.claim(
        token: token,
        now: _now(),
        limit: batchSize,
        ignoreBackoff: ignoreBackoff,
      );
      if (claimed.isEmpty) return const NothingToSend();
      try {
        final response = await _transport.upload(
          UploadBatch(
            apiKey: apiKey,
            sentAt: _now(),
            libraryVersion: trackLiteVersion,
            events: [for (final row in claimed) row.toEvent()],
          ),
        );
        await _database.transaction(() async {
          await events.markSent(token, _now());
          await _database.metaDao.increment(MetaKeys.sentTotal, claimed.length);
          await events.pruneSent(_now().subtract(keepSent));
        });
        onBatchSent(claimed.length);
        _logger.debug(
          'uploaded ${claimed.length} events '
          '(${response.accepted} new, ${response.duplicates} duplicates)',
        );
      } on TransportException catch (error) {
        return _failed(token, error);
      } on Object catch (error, stackTrace) {
        // A transport that broke its contract (threw something else): the
        // events go back, as if the server were unreachable.
        _logger.error('the transport failed', error, stackTrace);
        await events.release(token, 'transport error: $error');
        return Failed(
          reason: 'transport error: $error',
          remaining: await events.waitingCount(),
        );
      }
    }
  }

  Future<FlushResult> _failed(String token, TransportException error) async {
    final events = _database.eventDao;
    switch (error) {
      case RequestRejected():
        // The server refused these events themselves: sending them again
        // would be refused again. They are kept, as `failed`.
        await events.markFailed(token, error.message);
      case ServerUnreachable() || ServerFailure() || ApiKeyRejected():
        await events.release(token, error.message);
    }
    _logger.warning('upload failed: ${error.message}');
    if (error is ApiKeyRejected) return const Unauthorized();
    return Failed(
      reason: error.message,
      remaining: await events.waitingCount(),
    );
  }

  Future<void> _log(
    UploadTrigger trigger,
    DateTime startedAt,
    FlushResult result, {
    required int batches,
    required int events,
  }) async {
    final (outcome, error) = switch (result) {
      Uploaded() => ('uploaded', null),
      NothingToSend() => ('nothing', null),
      Offline() => ('offline', null),
      Failed(:final reason) => ('failed', reason),
      Unauthorized() => ('unauthorized', 'the API key was rejected'),
      NotInitialized() => ('nothing', null),
    };
    try {
      await _database.uploadDao.add(
        UploadsCompanion.insert(
          trigger: trigger.name,
          startedAt: startedAt,
          finishedAt: _now(),
          outcome: outcome,
          batches: Value(batches),
          events: Value(events),
          error: Value(error),
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.error('logging the upload failed', error, stackTrace);
    }
  }
}
