// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_dao.dart';

// ignore_for_file: type=lint
mixin _$LabDaoMixin on DatabaseAccessor<AppDatabase> {
  $LabResultsTable get labResults => attachedDatabase.labResults;
  LabDaoManager get managers => LabDaoManager(this);
}

class LabDaoManager {
  final _$LabDaoMixin _db;
  LabDaoManager(this._db);
  $$LabResultsTableTableManager get labResults =>
      $$LabResultsTableTableManager(_db.attachedDatabase, _db.labResults);
}
