import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

// The SDK's two tables, in its own database file (never the host's). They
// store rows and know nothing of the public models: the mapper turns a row
// into a `TrackLiteEvent`. The `CHECK`s are the last line of defence: a bug
// that slips past the validator fails loudly instead of storing a broken
// row, which would then fail every upload.
//
// Instants are UTC ISO-8601 text (conventions §11.14): each one must end in
// `Z`. The queue is ordered by `seq`, the insertion order, never by time
// (two events can share a timestamp, and a device's clock can move back).
//
// The constraints are written out as literals: drift_dev checks only those.

/// The event queue: every tracked event, from `pending` to `sent`.
@internal
@DataClassName('EventRow')
@TableIndex(name: 'events_by_status', columns: {#status, #seq})
class Events extends Table {
  /// The insertion order: uploads go oldest first by this, and so does
  /// dropping when the queue is full.
  IntColumn get seq => integer().autoIncrement()();

  /// The event's UUID: the server drops a second copy of the same id.
  TextColumn get id => text().unique()();

  TextColumn get name => text()();

  /// When it was tracked (the host's clock, in UTC).
  DateTimeColumn get timestamp => dateTime()();

  TextColumn get userId => text().nullable()();

  TextColumn get anonymousId => text()();

  /// A JSON object of `String`, number and `bool` values.
  TextColumn get properties => text()();

  /// `pending`, `sending`, `sent` or `failed`.
  TextColumn get status => text()();

  /// Server failures so far (failing to reach it doesn't count).
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// When an automatic upload may try it again.
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  /// Which upload claimed it, and when: set exactly while `sending`.
  TextColumn get claimToken => text().nullable()();

  DateTimeColumn get claimedAt => dateTime().nullable()();

  /// When the server accepted it: set exactly when `sent`.
  DateTimeColumn get sentAt => dateTime().nullable()();

  TextColumn get lastError => text().nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(id)) > 0)',
    'CHECK (length(trim(name)) > 0)',
    "CHECK (status IN ('pending', 'sending', 'sent', 'failed'))",
    'CHECK (attempts >= 0)',
    "CHECK (json_type(properties) = 'object')",
    'CHECK ("timestamp" GLOB \'*Z\')',
    "CHECK (next_attempt_at IS NULL OR next_attempt_at GLOB '*Z')",
    "CHECK (claimed_at IS NULL OR claimed_at GLOB '*Z')",
    "CHECK (sent_at IS NULL OR sent_at GLOB '*Z')",
    "CHECK ((status = 'sending') = (claim_token IS NOT NULL "
        'AND claimed_at IS NOT NULL))',
    "CHECK ((status = 'sent') = (sent_at IS NOT NULL))",
  ];
}

/// The SDK's own small facts, by name: the identity, the running totals,
/// and (Phase 4) the config the background task needs.
@internal
@DataClassName('MetaRow')
class MetaEntries extends Table {
  @override
  String get tableName => 'meta';

  TextColumn get name => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

/// One upload run: when, why it ran, and what came of it (schema v2). The
/// newest 100 are kept.
@internal
@DataClassName('UploadRow')
class Uploads extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// What started it: `manual`, `interval`, `threshold`, …
  TextColumn get trigger => text()();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get finishedAt => dateTime()();

  /// `uploaded`, `nothing`, `offline`, `failed` or `unauthorized`.
  TextColumn get outcome => text()();

  IntColumn get batches => integer().withDefault(const Constant(0))();

  IntColumn get events => integer().withDefault(const Constant(0))();

  TextColumn get error => text().nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (outcome IN ('uploaded', 'nothing', 'offline', 'failed', "
        "'unauthorized'))",
    'CHECK (batches >= 0 AND events >= 0)',
    "CHECK (started_at GLOB '*Z' AND finished_at GLOB '*Z')",
  ];
}
