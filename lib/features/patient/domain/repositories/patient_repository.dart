import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/result.dart';
import '../entities/patient_profile.dart';

/// Read/write access to the tracked patient's profile.
abstract interface class PatientRepository {
  Stream<Patient?> watchPatient();

  Future<Patient?> getPatient();

  /// Creates or updates the patient and (re)schedules the next dialysis
  /// session from the chosen weekdays.
  Future<Result<void>> saveProfile(PatientProfile profile);
}
