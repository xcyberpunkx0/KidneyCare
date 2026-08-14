// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_dao.dart';

// ignore_for_file: type=lint
mixin _$DoseDaoMixin on DatabaseAccessor<AppDatabase> {
  $DosesTable get doses => attachedDatabase.doses;
  DoseDaoManager get managers => DoseDaoManager(this);
}

class DoseDaoManager {
  final _$DoseDaoMixin _db;
  DoseDaoManager(this._db);
  $$DosesTableTableManager get doses =>
      $$DosesTableTableManager(_db.attachedDatabase, _db.doses);
}
