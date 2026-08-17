import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/lab_metric.dart';
import '../../../../shared/domain/timeline_event_type.dart';
import '../../domain/entities/lab_series.dart';
import '../../domain/repositories/labs_repository.dart';

class LabsRepositoryImpl implements LabsRepository {
  LabsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _uuid = Uuid();

  @override
  Stream<List<LabSeries>> watchAllSeries() {
    return _db.labDao.watchAll().asyncMap((rows) async {
      final patient = await _db.patientDao.getPatient();
      return _groupIntoSeries(rows, patient);
    });
  }

  @override
  Future<Result<void>> saveManualEntry({
    required DateTime takenAt,
    required Map<LabMetric, double> values,
  }) {
    return Result.guard(() async {
      await _db.transaction(() async {
        await _db.labDao.insertAll([
          for (final MapEntry(key: metric, value: value)
              in values.entries)
            LabResultsCompanion(
              id: Value(_uuid.v4()),
              metricCode: Value(metric.code),
              value: Value(value),
              takenAt: Value(takenAt),
            ),
        ]);
        await _db.timelineDao.insert(TimelineEventsCompanion(
          id: Value(_uuid.v4()),
          type: const Value(TimelineEventType.labReport),
          title: const Value('Lab values entered'),
          subtitle: Value('Manual entry · ${values.length} '
              'value${values.length == 1 ? '' : 's'}'),
          occurredAt: Value(takenAt),
        ));
      });
    });
  }

  @override
  Stream<List<LabReading>> watchReadings(LabMetric metric) {
    return _db.labDao.watchMetric(metric.code).map((rows) => [
          for (final row in rows.reversed)
            LabReading(id: row.id, takenAt: row.takenAt, value: row.value),
        ]);
  }

  @override
  Future<Result<void>> updateReading(String id, double value) {
    return Result.guard(() => _db.labDao.updateValue(id, value));
  }

  @override
  Future<Result<void>> deleteReading(String id) {
    return Result.guard(() => _db.labDao.deleteById(id));
  }

  List<LabSeries> _groupIntoSeries(List<LabResult> rows, Patient? patient) {
    final byMetric = <LabMetric, List<LabPoint>>{};
    for (final row in rows) {
      final metric = LabMetric.fromCode(row.metricCode);
      if (metric == null) continue;
      byMetric
          .putIfAbsent(metric, () => [])
          .add(LabPoint(takenAt: row.takenAt, value: row.value));
    }

    // The weight band is personal: dry weight ± 0.5 kg, not the
    // population constant baked into the metric.
    final dryWeight = patient?.dryWeightKg ?? 0;
    final isPersonalWeight = dryWeight > 0;

    return [
      for (final metric in LabMetric.values)
        if (byMetric.containsKey(metric))
          LabSeries(
            metric: metric,
            points: byMetric[metric]!,
            normalMinOverride: metric == LabMetric.weight && isPersonalWeight
                ? dryWeight - 0.5
                : null,
            normalMaxOverride: metric == LabMetric.weight && isPersonalWeight
                ? dryWeight + 0.5
                : null,
          ),
    ];
  }
}

final labsRepositoryProvider = Provider<LabsRepository>((ref) {
  return LabsRepositoryImpl(ref.watch(databaseProvider));
});

final labSeriesProvider = StreamProvider<List<LabSeries>>((ref) {
  return ref.watch(labsRepositoryProvider).watchAllSeries();
});
