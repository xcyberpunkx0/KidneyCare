import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'lab_dao.g.dart';

@DriftAccessor(tables: [LabResults])
class LabDao extends DatabaseAccessor<AppDatabase> with _$LabDaoMixin {
  LabDao(super.db);

  Stream<List<LabResult>> watchMetric(String metricCode) {
    final query = select(labResults)
      ..where((t) => t.metricCode.equals(metricCode))
      ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]);
    return query.watch();
  }

  /// Full history, oldest first — lets callers derive latest values and
  /// trends from a single stream.
  Stream<List<LabResult>> watchAll() {
    final query = select(labResults)
      ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]);
    return query.watch();
  }

  /// Latest observation per metric — feeds the home vitals tiles.
  Stream<List<LabResult>> watchLatestPerMetric() {
    final query = select(labResults)
      ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]);
    return query.watch().map((rows) {
      final seen = <String>{};
      final latest = <LabResult>[];
      for (final row in rows) {
        if (seen.add(row.metricCode)) latest.add(row);
      }
      return latest;
    });
  }

  Future<List<LabResult>> getMetricHistory(String metricCode) {
    final query = select(labResults)
      ..where((t) => t.metricCode.equals(metricCode))
      ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]);
    return query.get();
  }

  Future<List<LabResult>> getAll() {
    final query = select(labResults)
      ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]);
    return query.get();
  }

  Future<void> insertAll(List<LabResultsCompanion> entries) async {
    await batch((b) => b.insertAllOnConflictUpdate(labResults, entries));
  }

  Future<void> updateValue(String id, double value) {
    return (update(labResults)..where((t) => t.id.equals(id)))
        .write(LabResultsCompanion(value: Value(value)));
  }

  Future<void> deleteById(String id) =>
      (delete(labResults)..where((t) => t.id.equals(id))).go();
}
