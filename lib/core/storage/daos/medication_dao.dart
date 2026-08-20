import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'medication_dao.g.dart';

@DriftAccessor(tables: [Medications])
class MedicationDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationDaoMixin {
  MedicationDao(super.db);

  Stream<List<Medication>> watchActive() {
    final query = select(medications)
      ..where((t) => t.endDate.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  Stream<List<Medication>> watchEnded() {
    final query = select(medications)
      ..where((t) => t.endDate.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.endDate)]);
    return query.watch();
  }

  Stream<int> watchActiveCount() {
    final count = medications.id.count();
    final query = selectOnly(medications)
      ..addColumns([count])
      ..where(medications.endDate.isNull());
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Future<List<Medication>> search(String term) {
    final pattern = '%${term.toLowerCase()}%';
    final query = select(medications)
      ..where(
        (t) =>
            t.name.lower().like(pattern) |
            t.purpose.lower().like(pattern) |
            t.doctor.lower().like(pattern),
      );
    return query.get();
  }

  Future<Medication?> getById(String id) {
    final query = select(medications)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsert(MedicationsCompanion entry) {
    return into(medications).insertOnConflictUpdate(entry);
  }

  Future<void> deleteById(String id) =>
      (delete(medications)..where((t) => t.id.equals(id))).go();
}
