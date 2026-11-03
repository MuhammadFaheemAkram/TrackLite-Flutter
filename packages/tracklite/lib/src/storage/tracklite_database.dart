import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/storage/event_dao.dart';
import 'package:tracklite/src/storage/meta_dao.dart';
import 'package:tracklite/src/storage/tables.dart';
import 'package:tracklite/src/storage/tracklite_database.steps.dart';
import 'package:tracklite/src/storage/upload_dao.dart';

part 'tracklite_database.g.dart';

/// The SDK's own SQLite database, `tracklite.sqlite` in the app's documents
/// directory: never the host's database, so neither can break the other's
/// schema or migrations.
@internal
@DriftDatabase(
  tables: [Events, MetaEntries, Uploads],
  daos: [EventDao, MetaDao, UploadDao],
)
class TrackLiteDatabase extends _$TrackLiteDatabase {
  TrackLiteDatabase(super.executor);

  /// The database on the device.
  ///
  /// `shareAcrossIsolates`: the background upload runs in another isolate
  /// (sometimes while the app is open). With it, both use one connection
  /// through a shared isolate, so their writes are serialized, and the
  /// app's streams see the background's changes.
  TrackLiteDatabase.onDevice()
    : this(
        driftDatabase(
          name: 'tracklite',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  /// A fresh database in memory: for tests, and for a session whose file
  /// can't be opened. `closeStreamsSynchronously` lets widget tests end
  /// without waiting on drift's stream timers (conventions §11.24).
  TrackLiteDatabase.inMemory()
    : this(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );

  /// A change to the schema bumps this, exports the new version
  /// (`fvm dart run drift_dev make-migrations`) and ships a tested
  /// migration: an SDK's database upgrades in place on its users' devices.
  ///
  /// 1. The event queue and `meta`.
  /// 2. The `uploads` log.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: stepByStep(
      from1To2: (m, schema) => m.createTable(schema.uploads),
    ),
  );

  /// The queue's counts by status and the running totals, as one row, in
  /// one query that watches both tables: every write to either re-runs it.
  Stream<QueryRow> watchStatsRow() => customSelect(
    '''
    SELECT
      (SELECT COUNT(*) FROM events WHERE status = 'pending') AS pending,
      (SELECT COUNT(*) FROM events WHERE status = 'sending') AS sending,
      (SELECT value FROM meta WHERE name = 'sent_total') AS sent,
      (SELECT COUNT(*) FROM events WHERE status = 'failed') AS failed,
      (SELECT value FROM meta WHERE name = 'tracked_total') AS tracked,
      (SELECT value FROM meta WHERE name = 'dropped_total') AS dropped,
      (SELECT value FROM meta WHERE name = 'rejected_total') AS rejected,
      (SELECT value FROM meta WHERE name = 'user_id') AS user_id,
      (SELECT value FROM meta WHERE name = 'anonymous_id') AS anonymous_id,
      (SELECT next_attempt_at FROM events
        WHERE status = 'pending' AND next_attempt_at IS NOT NULL
        ORDER BY julianday(next_attempt_at) LIMIT 1) AS next_retry,
      (SELECT id FROM uploads ORDER BY id DESC LIMIT 1) AS last_upload
    ''',
    readsFrom: {events, metaEntries, uploads},
  ).watchSingle();
}

/// How the client opens its database: on the device, unless a host's tests
/// asked for memory (`TrackLiteTesting.useInMemoryDatabase`).
@internal
TrackLiteDatabase Function() openTrackLiteDatabase = TrackLiteDatabase.onDevice;
