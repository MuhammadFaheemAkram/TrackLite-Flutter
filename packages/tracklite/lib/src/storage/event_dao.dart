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

  // The upload pipeline. Times are compared with `julianday`, never as text
  // (conventions §11.60).

  /// Puts `sending` events claimed before [before] back to `pending`: their
  /// upload died (the app was killed mid-request, or another isolate was).
  /// Without this, a crash would leave them `sending` forever.
  Future<int> releaseExpiredClaims(DateTime before) => customUpdate(
    "UPDATE events SET status = 'pending', claim_token = NULL, "
    'claimed_at = NULL '
    "WHERE status = 'sending' AND julianday(claimed_at) < julianday(?)",
    variables: [Variable.withDateTime(before)],
    updates: {events},
    updateKind: UpdateKind.update,
  );

  /// Claims up to [limit] of the oldest due `pending` events for one upload,
  /// marking them `sending` with [token], in one statement, and returns
  /// them oldest first.
  ///
  /// One statement is what makes a claim safe: a second uploader (another
  /// isolate) running the same query gets the *next* events, never these.
  /// Due means never retried, or past its retry time; [ignoreBackoff] (an
  /// explicit flush) claims retries early too.
  Future<List<EventRow>> claim({
    required String token,
    required DateTime now,
    required int limit,
    bool ignoreBackoff = false,
  }) async {
    await customUpdate(
      "UPDATE events SET status = 'sending', claim_token = ?1, "
      'claimed_at = ?2 '
      'WHERE seq IN (SELECT seq FROM events '
      "WHERE status = 'pending' AND (?3 OR next_attempt_at IS NULL "
      'OR julianday(next_attempt_at) <= julianday(?2)) '
      'ORDER BY seq LIMIT ?4)',
      variables: [
        Variable.withString(token),
        Variable.withDateTime(now),
        Variable.withBool(ignoreBackoff),
        Variable.withInt(limit),
      ],
      updates: {events},
      updateKind: UpdateKind.update,
    );
    return (select(events)
          ..where((row) => row.claimToken.equals(token))
          ..orderBy([(row) => OrderingTerm.asc(row.seq)]))
        .get();
  }

  /// The server accepted the claim: `sent`, at [at].
  Future<int> markSent(String token, DateTime at) =>
      (update(events)..where((row) => row.claimToken.equals(token))).write(
        EventsCompanion(
          status: const Value('sent'),
          sentAt: Value(at),
          claimToken: const Value(null),
          claimedAt: const Value(null),
          lastError: const Value(null),
        ),
      );

  /// The upload failed in a way worth trying again: back to `pending`,
  /// with why.
  Future<int> release(String token, String error) =>
      (update(events)..where((row) => row.claimToken.equals(token))).write(
        EventsCompanion(
          status: const Value('pending'),
          claimToken: const Value(null),
          claimedAt: const Value(null),
          lastError: Value(error),
        ),
      );

  /// The server refused these events for good: `failed`, with why.
  Future<int> markFailed(String token, String error) =>
      (update(events)..where((row) => row.claimToken.equals(token))).write(
        EventsCompanion(
          status: const Value('failed'),
          claimToken: const Value(null),
          claimedAt: const Value(null),
          lastError: Value(error),
        ),
      );

  /// Deletes `sent` events older than [before]: kept a while for the debug
  /// tools, then gone (the total lives in a counter).
  Future<int> pruneSent(DateTime before) => customUpdate(
    "DELETE FROM events WHERE status = 'sent' "
    'AND julianday(sent_at) < julianday(?)',
    variables: [Variable.withDateTime(before)],
    updates: {events},
    updateKind: UpdateKind.delete,
  );

  /// A server failure for one claimed event: counted, then either back to
  /// `pending` until [retryAt], or `failed` when [retryAt] is `null` (it
  /// has used up its retries).
  Future<void> recordServerFailure({
    required int seq,
    required int attempts,
    required DateTime? retryAt,
    required String error,
  }) => (update(events)..where((row) => row.seq.equals(seq))).write(
    EventsCompanion(
      status: Value(retryAt == null ? 'failed' : 'pending'),
      attempts: Value(attempts),
      nextAttemptAt: Value(retryAt),
      claimToken: const Value(null),
      claimedAt: const Value(null),
      lastError: Value(error),
    ),
  );

  /// Pending events an automatic upload may send now (no retry wait left).
  Future<int> dueCount(DateTime now) => customSelect(
    "SELECT COUNT(*) AS n FROM events WHERE status = 'pending' "
    'AND (next_attempt_at IS NULL '
    'OR julianday(next_attempt_at) <= julianday(?))',
    variables: [Variable.withDateTime(now)],
    readsFrom: {events},
  ).map((row) => row.read<int>('n')).getSingle();

  /// The earliest time a pending event's retry wait ends, if any waits.
  Future<DateTime?> earliestRetryAt() =>
      (select(events)
            ..where(
              (row) =>
                  row.status.equals('pending') & row.nextAttemptAt.isNotNull(),
            )
            ..orderBy([
              (row) => OrderingTerm.asc(
                FunctionCallExpression<double>('julianday', [
                  row.nextAttemptAt,
                ]),
              ),
            ])
            ..limit(1))
          .map((row) => row.nextAttemptAt)
          .getSingleOrNull();

  /// The newest events first (any status): now, then after every change.
  Stream<List<EventRow>> watchNewest(int limit) =>
      (select(events)
            ..orderBy([(row) => OrderingTerm.desc(row.seq)])
            ..limit(limit))
          .watch();

  /// Puts every `failed` event back to `pending`, as if new (no attempts, no
  /// wait), and says how many.
  Future<int> retryFailed() =>
      (update(events)..where((row) => row.status.equals('failed'))).write(
        const EventsCompanion(
          status: Value('pending'),
          attempts: Value(0),
          nextAttemptAt: Value(null),
          lastError: Value(null),
        ),
      );

  /// Events that could still be uploaded now or later: pending or sending.
  Future<int> waitingCount() {
    final count = events.seq.count();
    return (selectOnly(events)
          ..addColumns([count])
          ..where(events.status.isIn(['pending', 'sending'])))
        .map((row) => row.read(count)!)
        .getSingle();
  }
}
