import 'dart:async';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/model/tracklite_event.dart';
import 'package:tracklite/src/model/tracklite_stats.dart';
import 'package:tracklite/src/model/upload_record.dart';
import 'package:tracklite/src/storage/event_mapper.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';
import 'package:tracklite/src/storage/upload_mapper.dart';
import 'package:tracklite/src/util/combine.dart';

/// Tools for seeing inside the SDK: what a debug screen or a support build
/// shows. Kept apart from the core calls, so the everyday API stays small.
abstract interface class TrackLiteDebug {
  /// The queue's counts, the identity, the next retry, the last upload,
  /// and whether the SDK is online and uploading: now, then after every
  /// change.
  Stream<TrackLiteStats> watchStats();

  /// The newest [limit] events, any status, newest first: now, then after
  /// every change.
  Stream<List<TrackLiteEvent>> watchRecentEvents({int limit = 20});

  /// The newest [limit] upload runs, newest first: now, then after every
  /// run.
  Stream<List<UploadRecord>> watchUploads({int limit = 10});

  /// Puts every `failed` event back in the queue, as if new, and says how
  /// many. They go with the next upload; `flush()` sends them now.
  Future<int> retryFailed();
}

/// The debug tools: the database's facts, and the client's live ones (the
/// network, an upload in flight).
@internal
final class DatabaseDebug implements TrackLiteDebug {
  const DatabaseDebug(
    this._database, {
    required this._watchOnline,
    required this._watchUploading,
  });

  final TrackLiteDatabase _database;
  final Stream<bool> Function() _watchOnline;
  final Stream<bool> Function() _watchUploading;

  @override
  Stream<TrackLiteStats> watchStats() => combineLatest3(
    () => _database.watchStatsRow().asyncMap(_statsOf),
    _watchOnline,
    _watchUploading,
    (stats, online, uploading) =>
        stats.copyWith(isOnline: online, isUploading: uploading),
  );

  @override
  Stream<List<TrackLiteEvent>> watchRecentEvents({int limit = 20}) => _database
      .eventDao
      .watchNewest(limit)
      .map((rows) => [for (final row in rows) row.toEvent()]);

  @override
  Stream<List<UploadRecord>> watchUploads({int limit = 10}) => _database
      .uploadDao
      .watchNewest(limit: limit)
      .map((rows) => [for (final row in rows) row.toRecord()]);

  @override
  Future<int> retryFailed() => _database.eventDao.retryFailed();

  Future<TrackLiteStats> _statsOf(QueryRow row) async {
    int counter(String column) =>
        int.parse(row.readNullable<String>(column) ?? '0');
    final lastUploadId = row.readNullable<int>('last_upload');
    final nextRetry = row.readNullable<String>('next_retry');
    return TrackLiteStats(
      tracked: counter('tracked'),
      pending: row.read<int>('pending'),
      sending: row.read<int>('sending'),
      sent: counter('sent'),
      failed: row.read<int>('failed'),
      dropped: counter('dropped'),
      rejected: counter('rejected'),
      userId: row.readNullable<String>('user_id'),
      anonymousId: row.readNullable<String>('anonymous_id') ?? '',
      nextRetryAt: nextRetry == null ? null : DateTime.parse(nextRetry),
      lastUpload: lastUploadId == null
          ? null
          : (await _database.uploadDao.byId(lastUploadId))?.toRecord(),
    );
  }
}

extension on TrackLiteStats {
  TrackLiteStats copyWith({
    required bool isOnline,
    required bool isUploading,
  }) => TrackLiteStats(
    anonymousId: anonymousId,
    tracked: tracked,
    pending: pending,
    sending: sending,
    sent: sent,
    failed: failed,
    dropped: dropped,
    rejected: rejected,
    userId: userId,
    nextRetryAt: nextRetryAt,
    lastUpload: lastUpload,
    isOnline: isOnline,
    isUploading: isUploading,
  );
}
