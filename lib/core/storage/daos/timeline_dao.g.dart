// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_dao.dart';

// ignore_for_file: type=lint
mixin _$TimelineDaoMixin on DatabaseAccessor<AppDatabase> {
  $TimelineEventsTable get timelineEvents => attachedDatabase.timelineEvents;
  TimelineDaoManager get managers => TimelineDaoManager(this);
}

class TimelineDaoManager {
  final _$TimelineDaoMixin _db;
  TimelineDaoManager(this._db);
  $$TimelineEventsTableTableManager get timelineEvents =>
      $$TimelineEventsTableTableManager(
        _db.attachedDatabase,
        _db.timelineEvents,
      );
}
