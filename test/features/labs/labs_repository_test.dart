import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/features/labs/data/repository_impl/labs_repository_impl.dart';
import 'package:recora/shared/domain/lab_metric.dart';

void main() {
  late AppDatabase db;
  late LabsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LabsRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> seedReading(String id, double value, DateTime takenAt,
      {LabMetric metric = LabMetric.hemoglobin}) {
    return db.labDao.insertAll([
      LabResultsCompanion(
        id: Value(id),
        metricCode: Value(metric.code),
        value: Value(value),
        takenAt: Value(takenAt),
      ),
    ]);
  }

  test('watchReadings emits the metric history newest first, with ids',
      () async {
    await seedReading('older', 8.7, DateTime(2026, 6, 10));
    await seedReading('newer', 9.1, DateTime(2026, 8, 2));
    await seedReading('other-metric', 3.2, DateTime(2026, 8, 2),
        metric: LabMetric.whiteBloodCells);

    final readings = await repo.watchReadings(LabMetric.hemoglobin).first;

    expect(readings.map((r) => r.id), ['newer', 'older']);
    expect(readings.first.value, 9.1);
    expect(readings.first.takenAt, DateTime(2026, 8, 2));
  });

  test('updateReading rewrites the value and keeps the date', () async {
    final takenAt = DateTime(2026, 8, 2);
    await seedReading('r1', 78.0, takenAt);

    final result = await repo.updateReading('r1', 8.7);
    expect(result.isOk, isTrue);

    final rows = await db.select(db.labResults).get();
    expect(rows.single.value, 8.7);
    expect(rows.single.takenAt, takenAt);
  });

  test('deleteReading removes only the targeted row', () async {
    await seedReading('keep', 8.7, DateTime(2026, 6, 10));
    await seedReading('drop', 78.0, DateTime(2026, 8, 2));

    final result = await repo.deleteReading('drop');
    expect(result.isOk, isTrue);

    final rows = await db.select(db.labResults).get();
    expect(rows.single.id, 'keep');
  });
}
