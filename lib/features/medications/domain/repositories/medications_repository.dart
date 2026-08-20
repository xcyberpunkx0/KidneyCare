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

  /// The stored row, for prefilling the edit form. Null when [id] is
  /// unknown.
  Future<Medication?> getMedication(String id);

  /// Rewrites a medication's details in place. Start and end dates are
  /// kept; a correction is not a timeline event.
  Future<Result<void>> updateManual(String id, NewMedication medication);

  /// Erases a mistaken entry: the medication, its dose-strip rows, and
  /// the timeline entries recorded for it. A medicine that was really
  /// taken and then stopped should be ended, not deleted.
  Future<Result<void>> deleteMedication(String id);
}
