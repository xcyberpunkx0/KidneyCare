import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  PatientRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _patientId = 'patient-1';

  @override
  Stream<Patient?> watchPatient() => _db.patientDao.watchPatient();

  @override
  Future<Patient?> getPatient() => _db.patientDao.getPatient();

  @override
  Future<Result<void>> saveProfile(PatientProfile profile) {
    return Result.guard(() async {
      await _db.transaction(() async {
        await _db.patientDao.upsert(PatientsCompanion(
          id: const Value(_patientId),
          name: Value(profile.name),
          initials: Value(profile.initials),
          age: Value(profile.age),
          conditionSummary: Value(profile.conditionSummary),
          dialysisCenter: Value(profile.center),
          dryWeightKg: Value(profile.dryWeightKg),
          dryWeightDeltaKg: const Value(0),
          scheduleJson: Value(profile.scheduleToJson()),
          bloodGroup: Value(profile.bloodGroup),
          allergies: Value(profile.allergies),
          emergencyContact: Value(profile.emergencyContact),
          comorbidities: Value(profile.comorbidities),
        ));

        final next = profile.nextSession(DateTime.now());
        if (next != null) {
          await _db.dialysisDao.upsert(DialysisSessionsCompanion(
            id: const Value('hd-next'),
            scheduledAt: Value(next),
            completed: const Value(false),
            center: Value(profile.center),
          ));
        }
      });
    });
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(ref.watch(databaseProvider));
});

final patientProvider = StreamProvider<Patient?>((ref) {
  return ref.watch(patientRepositoryProvider).watchPatient();
});
