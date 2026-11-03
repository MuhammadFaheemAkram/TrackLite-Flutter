import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/storage/event_dao.dart';
import 'package:tracklite/src/storage/meta_dao.dart';
import 'package:tracklite/src/storage/tables.dart';

part 'tracklite_database.g.dart';

/// The SDK's own SQLite database, `tracklite.sqlite` in the app's documents
/// directory: never the host's database, so neither can break the other's
/// schema or migrations.
@internal
@DriftDatabase(tables: [Events, MetaEntries], daos: [EventDao, MetaDao])
class TrackLiteDatabase extends _$TrackLiteDatabase {
  TrackLiteDatabase(super.executor);

  /// The database on the device.
  TrackLiteDatabase.onDevice() : this(driftDatabase(name: 'tracklite'));

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
  @override
  int get schemaVersion => 1;

  /// The queue's counts by status and the running totals, as one row, in
  /// one query that watches both tables: every write to either re-runs it.
  Stream<QueryRow> watchStatsRow() => customSelect(
    '''
    SELECT
      (SELECT COUNT(*) FROM events WHERE status = 'pending') AS pending,
      (SELECT COUNT(*) FROM events WHERE status = 'sending') AS sending,
      (SELECT COUNT(*) FROM events WHERE status = 'sent') AS sent,
      (SELECT COUNT(*) FROM events WHERE status = 'failed') AS failed,
      (SELECT value FROM meta WHERE name = 'tracked_total') AS tracked,
      (SELECT value FROM meta WHERE name = 'dropped_total') AS dropped,
      (SELECT value FROM meta WHERE name = 'rejected_total') AS rejected,
      (SELECT value FROM meta WHERE name = 'user_id') AS user_id,
      (SELECT value FROM meta WHERE name = 'anonymous_id') AS anonymous_id
    ''',
    readsFrom: {events, metaEntries},
  ).watchSingle();
}

/// How the client opens its database: on the device, unless a host's tests
/// asked for memory (`TrackLiteTesting.useInMemoryDatabase`).
@internal
TrackLiteDatabase Function() openTrackLiteDatabase = TrackLiteDatabase.onDevice;
