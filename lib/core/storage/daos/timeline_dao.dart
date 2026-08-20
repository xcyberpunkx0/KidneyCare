import 'package:drift/drift.dart';

import '../../../shared/domain/timeline_event_type.dart';
import '../app_database.dart';
import '../tables.dart';

part 'timeline_dao.g.dart';

@DriftAccessor(tables: [TimelineEvents])
class TimelineDao extends DatabaseAccessor<AppDatabase>
    with _$TimelineDaoMixin {
  TimelineDao(super.db);

  /// Newest-first page of timeline events. Paged so years of history never
  /// load at once.
  Future<List<TimelineEvent>> getPage({
    required int limit,
    required int offset,
  }) {
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
      ..where(
        (t) => t.title.lower().like(pattern) | t.subtitle.lower().like(pattern),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return query.get();
  }

  Future<void> insert(TimelineEventsCompanion entry) {
    return into(timelineEvents).insertOnConflictUpdate(entry);
  }

  /// Removes the auto-created event a deleted record left behind, found by
  /// its type and exact timestamp (events store no link to their source).
  Future<void> deleteByTypeAt(TimelineEventType type, DateTime at) {
    return (delete(
      timelineEvents,
    )..where((t) => t.type.equalsValue(type) & t.occurredAt.equals(at))).go();
  }

  /// Removes events of [type] whose title is any of [titles] — e.g. the
  /// "Started X" / "Stopped X" entries of a medication being deleted.
  Future<void> deleteByTypeAndTitles(
    TimelineEventType type,
    List<String> titles,
  ) {
    return (delete(
      timelineEvents,
    )..where((t) => t.type.equalsValue(type) & t.title.isIn(titles))).go();
  }
}
