import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/storage/tables.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

part 'meta_dao.g.dart';

/// Reads and writes the `meta` table: named strings and counters.
@internal
@DriftAccessor(tables: [MetaEntries])
class MetaDao extends DatabaseAccessor<TrackLiteDatabase> with _$MetaDaoMixin {
  MetaDao(super.attachedDatabase);

  Future<String?> read(String name) =>
      (select(metaEntries)..where((row) => row.name.equals(name)))
          .map((row) => row.value)
          .getSingleOrNull();

  Future<void> write(String name, String value) =>
      into(metaEntries)
          .insertOnConflictUpdate(MetaRow(name: name, value: value));

  Future<void> remove(String name) =>
      (delete(metaEntries)..where((row) => row.name.equals(name))).go();

  /// Adds [by] to the counter [name], starting from 0, in one statement.
  Future<void> increment(String name, int by) => customStatement(
    'INSERT INTO meta (name, value) VALUES (?, ?) '
    'ON CONFLICT (name) DO UPDATE SET '
    'value = CAST(CAST(value AS INTEGER) + excluded.value AS TEXT)',
    [name, '$by'],
  );
}
