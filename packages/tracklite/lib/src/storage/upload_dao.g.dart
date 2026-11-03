// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'upload_dao.dart';

// ignore_for_file: type=lint
mixin _$UploadDaoMixin on DatabaseAccessor<TrackLiteDatabase> {
  $UploadsTable get uploads => attachedDatabase.uploads;
  UploadDaoManager get managers => UploadDaoManager(this);
}

class UploadDaoManager {
  final _$UploadDaoMixin _db;
  UploadDaoManager(this._db);
  $$UploadsTableTableManager get uploads =>
      $$UploadsTableTableManager(_db.attachedDatabase, _db.uploads);
}
