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

  /// The stored session as an editable [SessionLog] — blood pressure is
  /// read back from the lab observations recorded with it. Null when [id]
  /// is unknown.
  Future<SessionLog?> getSessionLog(String id);

  /// Rewrites a logged session and the weight/BP observations and timeline
  /// entry it created. The standing "next session" schedule is untouched.
  Future<Result<void>> updateSession(String id, SessionLog log);

  /// Removes a logged session along with the weight/BP observations and
  /// timeline entry it created.
  Future<Result<void>> deleteSession(String id);
}
