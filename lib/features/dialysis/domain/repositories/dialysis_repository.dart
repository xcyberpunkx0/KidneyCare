import '../../../../core/utils/result.dart';
import '../entities/session_log.dart';

/// Recording of dialysis sessions and maintenance of the schedule.
abstract interface class DialysisRepository {
  /// Records a completed session.
  ///
  /// Parameters:
  ///   - log: the session details as entered by the caregiver.
  ///
  /// Completes the pending scheduled session (or creates one), schedules
  /// the next session from the patient's weekly schedule, stores post
  /// weight and blood pressure as lab observations, and adds a timeline
  /// entry.
  ///
  /// Returns:
  ///   Ok on success; Err with a [StorageFailure] when persistence fails.
  Future<Result<void>> logSession(SessionLog log);
}
