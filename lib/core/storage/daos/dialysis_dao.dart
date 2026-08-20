import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'dialysis_dao.g.dart';

@DriftAccessor(tables: [DialysisSessions])
class DialysisDao extends DatabaseAccessor<AppDatabase>
    with _$DialysisDaoMixin {
  DialysisDao(super.db);

  Stream<DialysisSession?> watchNextSession(DateTime after) {
    final query = select(dialysisSessions)
      ..where(
        (t) =>
            t.completed.equals(false) &
            t.scheduledAt.isBiggerOrEqualValue(after),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  /// Completed sessions, most recent first.
  Stream<List<DialysisSession>> watchCompleted() {
    final query = select(dialysisSessions)
      ..where((t) => t.completed.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)]);
    return query.watch();
  }

  Stream<DialysisSession?> watchLastCompleted() {
    final query = select(dialysisSessions)
      ..where((t) => t.completed.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  Future<DialysisSession?> getById(String id) {
    final query = select(dialysisSessions)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(DialysisSessionsCompanion entry) {
    return into(dialysisSessions).insertOnConflictUpdate(entry);
  }

  Future<void> deleteById(String id) =>
      (delete(dialysisSessions)..where((t) => t.id.equals(id))).go();
}
