import 'package:meta/meta.dart';
import 'package:tracklite/src/model/upload_record.dart';
import 'package:tracklite/src/storage/tracklite_database.dart';

/// A logged run as the public record the debug tools show.
@internal
extension UploadRowMapper on UploadRow {
  UploadRecord toRecord() => UploadRecord(
    trigger: trigger,
    startedAt: startedAt,
    finishedAt: finishedAt,
    outcome: outcome,
    batches: batches,
    events: events,
    error: error,
  );
}
