import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'timeline_dao.g.dart';

@DriftAccessor(tables: [TimelineEvents])
class TimelineDao extends DatabaseAccessor<AppDatabase>
    with _$TimelineDaoMixin {
  TimelineDao(super.db);

  /// Newest-first page of timeline events. Paged so years of history never
  /// load at once.
  Future<List<TimelineEvent>> getPage({required int limit, required int offset}) {
    final query = select(timelineEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Stream<List<TimelineEvent>> watchRecent(int limit) {
    final query = select(timelineEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
      ..limit(limit);
    return query.watch();
  }

  Future<List<TimelineEvent>> search(String term) {
    final pattern = '%${term.toLowerCase()}%';
    final query = select(timelineEvents)
      ..where((t) =>
          t.title.lower().like(pattern) | t.subtitle.lower().like(pattern))
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return query.get();
  }

  Future<void> insert(TimelineEventsCompanion entry) {
    return into(timelineEvents).insertOnConflictUpdate(entry);
  }
}
