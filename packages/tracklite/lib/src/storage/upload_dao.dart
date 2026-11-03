import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tracklite/src/storage/tables.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

part 'upload_dao.g.dart';

/// The upload log.
@internal
@DriftAccessor(tables: [Uploads])
class UploadDao extends DatabaseAccessor<TrackLiteDatabase>
    with _$UploadDaoMixin {
  UploadDao(super.attachedDatabase);

  /// How many runs the log keeps.
  static const keep = 100;

  /// Adds a run, then trims the log to the newest [keep].
  Future<void> add(UploadsCompanion run) => transaction(() async {
    await into(uploads).insert(run);
    await customUpdate(
      'DELETE FROM uploads WHERE id NOT IN '
      '(SELECT id FROM uploads ORDER BY id DESC LIMIT ?)',
      variables: [Variable.withInt(keep)],
      updates: {uploads},
      updateKind: UpdateKind.delete,
    );
  });

  /// The newest runs first.
  Future<List<UploadRow>> newest({int limit = keep}) =>
      (select(uploads)
            ..orderBy([(row) => OrderingTerm.desc(row.id)])
            ..limit(limit))
          .get();
}
