// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'meta_dao.dart';

// ignore_for_file: type=lint
mixin _$MetaDaoMixin on DatabaseAccessor<TrackLiteDatabase> {
  $MetaEntriesTable get metaEntries => attachedDatabase.metaEntries;
  MetaDaoManager get managers => MetaDaoManager(this);
}

class MetaDaoManager {
  final _$MetaDaoMixin _db;
  MetaDaoManager(this._db);
  $$MetaEntriesTableTableManager get metaEntries =>
      $$MetaEntriesTableTableManager(_db.attachedDatabase, _db.metaEntries);
}
