import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/storage/tables.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

part 'event_dao.g.dart';

/// The event queue's SQL.
@internal
@DriftAccessor(tables: [Events])
class EventDao extends DatabaseAccessor<TrackLiteDatabase>
    with _$EventDaoMixin {
  EventDao(super.attachedDatabase);

  /// Appends [rows] in order; each gets the next `seq`.
  Future<void> insertAll(List<EventsCompanion> rows) =>
      batch((batch) => batch.insertAll(events, rows));

  /// Events not yet accepted by the server: pending, sending or failed.
  Future<int> unsentCount() {
    final count = events.seq.count();
    return (selectOnly(events)
          ..addColumns([count])
          ..where(events.status.equals('sent').not()))
        .map((row) => row.read(count)!)
        .getSingle();
  }

  /// Deletes the [count] oldest unsent events that no upload holds
  /// (`pending` or `failed`; a `sending` one is in flight), and says how
  /// many went.
  Future<int> dropOldestUnsent(int count) => customUpdate(
    'DELETE FROM events WHERE seq IN (SELECT seq FROM events '
    "WHERE status IN ('pending', 'failed') ORDER BY seq LIMIT ?)",
    variables: [Variable.withInt(count)],
    updates: {events},
    updateKind: UpdateKind.delete,
  );

  /// Every event, oldest first (for tests and, later, the debug tools).
  Future<List<EventRow>> all() =>
      (select(events)..orderBy([(row) => OrderingTerm.asc(row.seq)])).get();
}
