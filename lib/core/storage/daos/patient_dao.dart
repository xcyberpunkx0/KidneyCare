import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'patient_dao.g.dart';

@DriftAccessor(tables: [Patients])
class PatientDao extends DatabaseAccessor<AppDatabase> with _$PatientDaoMixin {
  PatientDao(super.db);

  Stream<Patient?> watchPatient() {
    return (select(patients)..limit(1)).watchSingleOrNull();
  }

  Future<Patient?> getPatient() {
    return (select(patients)..limit(1)).getSingleOrNull();
  }

  Future<void> upsert(PatientsCompanion entry) {
    return into(patients).insertOnConflictUpdate(entry);
  }
}
