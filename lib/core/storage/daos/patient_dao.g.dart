// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_dao.dart';

// ignore_for_file: type=lint
mixin _$PatientDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  PatientDaoManager get managers => PatientDaoManager(this);
}

class PatientDaoManager {
  final _$PatientDaoMixin _db;
  PatientDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
}
