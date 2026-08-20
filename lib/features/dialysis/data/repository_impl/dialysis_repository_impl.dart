import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/lab_metric.dart';
import '../../../../shared/domain/timeline_event_type.dart';
import '../../../patient/domain/entities/patient_profile.dart';
import '../../domain/entities/session_log.dart';
import '../../domain/repositories/dialysis_repository.dart';

class DialysisRepositoryImpl implements DialysisRepository {
  DialysisRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _uuid = Uuid();

  @override
  Future<Result<void>> logSession(SessionLog log) {
    return Result.guard(() async {
      final patient = await _db.patientDao.getPatient();

      await _db.transaction(() async {
        // Complete the pending scheduled session (kept under its own id so
        // history accumulates one row per session).
        await _db.dialysisDao.upsert(
          DialysisSessionsCompanion(
            id: Value(_uuid.v4()),
            scheduledAt: Value(log.completedAt),
            completed: const Value(true),
            center: Value(patient?.dialysisCenter ?? ''),
            ultrafiltrationL: Value(log.ultrafiltrationL),
            preWeightKg: Value(log.preWeightKg),
            postWeightKg: Value(log.postWeightKg),
            durationHours: Value(log.durationHours),
            note: Value(log.note),
          ),
        );

        // Roll the standing "next session" forward from the weekly
        // schedule.
        if (patient != null) {
          final schedule = PatientProfile.scheduleFromJson(
            patient.scheduleJson,
          );
          final profile = PatientProfile(
            name: patient.name,
            age: patient.age,
            condition: '',
            schedule: schedule,
            center: patient.dialysisCenter,
            dryWeightKg: patient.dryWeightKg,
          );
          // A backdated log must not drag the standing "next session"
          // into the past — roll forward from now in that case.
          final now = DateTime.now();
          final anchor = log.completedAt.isAfter(now) ? log.completedAt : now;
          final next = profile.nextSession(anchor);
          if (next != null) {
            await _db.dialysisDao.upsert(
              DialysisSessionsCompanion(
                id: const Value('hd-next'),
                scheduledAt: Value(next),
                completed: const Value(false),
                center: Value(patient.dialysisCenter),
                ultrafiltrationL: const Value(null),
                preWeightKg: const Value(null),
                postWeightKg: const Value(null),
                note: const Value(''),
              ),
            );
          }
        }

        await _insertSideEffects(log);
      });
    });
  }

  /// The metrics a session log writes as lab observations; their rows are
  /// found again by this set plus the session's exact timestamp.
  static final _sessionMetricCodes = [
    LabMetric.weight.code,
    LabMetric.bloodPressureSystolic.code,
    LabMetric.bloodPressureDiastolic.code,
  ];

  @override
  Future<SessionLog?> getSessionLog(String id) async {
    final session = await _db.dialysisDao.getById(id);
    if (session == null) return null;
    final vitals = await _db.labDao.getByMetricsAt(
      _sessionMetricCodes,
      session.scheduledAt,
    );
    double? metricValue(LabMetric metric) =>
        vitals.where((row) => row.metricCode == metric.code).firstOrNull?.value;
    return SessionLog(
      completedAt: session.scheduledAt,
      durationHours: session.durationHours ?? 4,
      preWeightKg: session.preWeightKg,
      postWeightKg: session.postWeightKg,
      ultrafiltrationL: session.ultrafiltrationL,
      systolic: metricValue(LabMetric.bloodPressureSystolic),
      diastolic: metricValue(LabMetric.bloodPressureDiastolic),
      note: session.note,
    );
  }

  @override
  Future<Result<void>> updateSession(String id, SessionLog log) {
    return Result.guard(() async {
      final session = await _db.dialysisDao.getById(id);
      if (session == null) return;
      await _db.transaction(() async {
        await _deleteSideEffects(session.scheduledAt);
        await _db.dialysisDao.upsert(
          DialysisSessionsCompanion(
            id: Value(id),
            scheduledAt: Value(log.completedAt),
            completed: const Value(true),
            center: Value(session.center),
            ultrafiltrationL: Value(log.ultrafiltrationL),
            preWeightKg: Value(log.preWeightKg),
            postWeightKg: Value(log.postWeightKg),
            durationHours: Value(log.durationHours),
            note: Value(log.note),
          ),
        );
        await _insertSideEffects(log);
      });
    });
  }

  @override
  Future<Result<void>> deleteSession(String id) {
    return Result.guard(() async {
      final session = await _db.dialysisDao.getById(id);
      if (session == null) return;
      await _db.transaction(() async {
        await _deleteSideEffects(session.scheduledAt);
        await _db.dialysisDao.deleteById(id);
      });
    });
  }

  /// Removes the lab observations and timeline entry a session log wrote,
  /// matched by their exact shared timestamp.
  Future<void> _deleteSideEffects(DateTime at) async {
    await _db.labDao.deleteByMetricsAt(_sessionMetricCodes, at);
    await _db.timelineDao.deleteByTypeAt(TimelineEventType.dialysis, at);
  }

  Future<void> _insertSideEffects(SessionLog log) async {
    await _db.labDao.insertAll([
      if (log.postWeightKg != null)
        _lab(LabMetric.weight, log.postWeightKg!, log.completedAt),
      if (log.systolic != null)
        _lab(LabMetric.bloodPressureSystolic, log.systolic!, log.completedAt),
      if (log.diastolic != null)
        _lab(LabMetric.bloodPressureDiastolic, log.diastolic!, log.completedAt),
    ]);
    await _db.timelineDao.insert(
      TimelineEventsCompanion(
        id: Value(_uuid.v4()),
        type: const Value(TimelineEventType.dialysis),
        title: Value(
          'Dialysis session · '
          '${log.durationHours.toStringAsFixed(log.durationHours % 1 == 0 ? 0 : 1)} h',
        ),
        subtitle: Value(log.summaryLine),
        occurredAt: Value(log.completedAt),
      ),
    );
  }

  LabResultsCompanion _lab(LabMetric metric, double value, DateTime at) {
    return LabResultsCompanion(
      id: Value(_uuid.v4()),
      metricCode: Value(metric.code),
      value: Value(value),
      takenAt: Value(at),
    );
  }
}

final dialysisRepositoryProvider = Provider<DialysisRepository>((ref) {
  return DialysisRepositoryImpl(ref.watch(databaseProvider));
});
