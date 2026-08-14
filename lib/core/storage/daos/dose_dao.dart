import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'dose_dao.g.dart';

@DriftAccessor(tables: [Doses])
class DoseDao extends DatabaseAccessor<AppDatabase> with _$DoseDaoMixin {
  DoseDao(super.db);

  Stream<List<Dose>> watchForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query = select(doses)
      ..where((t) =>
          t.scheduledOn.isBiggerOrEqualValue(start) &
          t.scheduledOn.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch();
  }

  Future<void> setTaken(String id, {required bool taken}) {
    return (update(doses)..where((t) => t.id.equals(id)))
        .write(DosesCompanion(taken: Value(taken)));
  }

  Future<void> insertAll(List<DosesCompanion> entries) async {
    await batch((b) => b.insertAllOnConflictUpdate(doses, entries));
  }
}
