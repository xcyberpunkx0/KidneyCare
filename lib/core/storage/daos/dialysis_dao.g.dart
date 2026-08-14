// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialysis_dao.dart';

// ignore_for_file: type=lint
mixin _$DialysisDaoMixin on DatabaseAccessor<AppDatabase> {
  $DialysisSessionsTable get dialysisSessions =>
      attachedDatabase.dialysisSessions;
  DialysisDaoManager get managers => DialysisDaoManager(this);
}

class DialysisDaoManager {
  final _$DialysisDaoMixin _db;
  DialysisDaoManager(this._db);
  $$DialysisSessionsTableTableManager get dialysisSessions =>
      $$DialysisSessionsTableTableManager(
        _db.attachedDatabase,
        _db.dialysisSessions,
      );
}
