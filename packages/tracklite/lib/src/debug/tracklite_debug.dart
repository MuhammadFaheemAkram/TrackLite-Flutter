import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/model/tracklite_stats.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

/// Tools for seeing inside the SDK: what a debug screen or a support build
/// shows. Kept apart from the core calls, so the everyday API stays small.
abstract interface class TrackLiteDebug {
  /// The queue's counts and the identity: now, then after every change.
  Stream<TrackLiteStats> watchStats();
}

/// The debug tools, read straight from the SDK's database.
@internal
final class DatabaseDebug implements TrackLiteDebug {
  const DatabaseDebug(this._database);

  final TrackLiteDatabase _database;

  @override
  Stream<TrackLiteStats> watchStats() =>
      _database.watchStatsRow().map(_statsOf);

  static TrackLiteStats _statsOf(QueryRow row) {
    int counter(String column) =>
        int.parse(row.readNullable<String>(column) ?? '0');
    return TrackLiteStats(
      tracked: counter('tracked'),
      pending: row.read<int>('pending'),
      sending: row.read<int>('sending'),
      sent: row.read<int>('sent'),
      failed: row.read<int>('failed'),
      dropped: counter('dropped'),
      rejected: counter('rejected'),
      userId: row.readNullable<String>('user_id'),
      anonymousId: row.readNullable<String>('anonymous_id') ?? '',
    );
  }
}
