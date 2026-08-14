import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/result.dart';
import '../entities/new_medication.dart';

/// Access to the medication list.
abstract interface class MedicationsRepository {
  Stream<List<Medication>> watchActive();

  Stream<List<Medication>> watchEnded();

  /// Adds a manually entered medicine and records the start on the
  /// timeline. Used when there is no prescription to photograph.
  Future<Result<void>> addManual(NewMedication medication);

  /// Marks a medication ended today.
  Future<Result<void>> endMedication(String id);
}
