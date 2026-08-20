import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/features/medications/data/repository_impl/medications_repository_impl.dart';
import 'package:recora/features/medications/domain/entities/new_medication.dart';
import 'package:recora/shared/domain/med_schedule.dart';
import 'package:recora/shared/domain/timeline_event_type.dart';

void main() {
  late AppDatabase db;
  late MedicationsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MedicationsRepositoryImpl(db);
  });
  tearDown(() => db.close());

  NewMedication entry(String name) => NewMedication(
    name: name,
    frequencyCode: '1-0-1',
    purpose: 'Phosphate binder',
    doctor: 'Dr. Rao',
    scheduleGroup: MedScheduleGroup.withFood,
    timingCues: const {MedTimingCue.withFood},
    scheduleNote: '',
    startDate: DateTime(2026, 8, 1),
  );

  test(
    'addManual keeps strength in the name and the dose column empty',
    () async {
      await repo.addManual(entry('Sevelamer 400 mg'));

      final med = (await db.select(db.medications).get()).single;
      expect(med.name, 'Sevelamer 400 mg');
      expect(med.dose, isEmpty);

      final events = await db.timelineDao.getPage(limit: 10, offset: 0);
      expect(events.single.title, 'Started Sevelamer 400 mg');
    },
  );

  test('deleteMedication removes the medicine, its doses and its timeline '
      'entries, leaving other medicines alone', () async {
    await repo.addManual(entry('Sevelamer 400 mg'));
    await repo.addManual(entry('Amlodipine 5 mg'));
    final meds = await db.select(db.medications).get();
    final target = meds.firstWhere((m) => m.name == 'Sevelamer 400 mg');

    await db.doseDao.insertAll([
      DosesCompanion(
        id: const Value('dose-1'),
        medicationId: Value(target.id),
        medicationLabel: const Value('Sevelamer'),
        timeLabel: const Value('8:00 AM'),
        sortOrder: const Value(0),
        scheduledOn: Value(DateTime(2026, 8, 20)),
      ),
    ]);
    await repo.endMedication(target.id);

    final result = await repo.deleteMedication(target.id);
    expect(result.isOk, isTrue);

    final remaining = await db.select(db.medications).get();
    expect(remaining.single.name, 'Amlodipine 5 mg');

    expect(await db.select(db.doses).get(), isEmpty);

    final events = await db.timelineDao.getPage(limit: 10, offset: 0);
    expect(events.single.title, 'Started Amlodipine 5 mg');
  });

  test('updateManual rewrites details but keeps the start date', () async {
    await repo.addManual(entry('Sevelamer 40 mg'));
    final med = (await db.select(db.medications).get()).single;

    final result = await repo.updateManual(
      med.id,
      NewMedication(
        name: 'Sevelamer 400 mg',
        frequencyCode: '1-1-1',
        purpose: 'Phosphate binder',
        doctor: 'Dr. Rao',
        scheduleGroup: MedScheduleGroup.byClock,
        timingCues: const {MedTimingCue.morning},
        scheduleNote: 'after breakfast',
        startDate: DateTime(2026, 8, 19),
      ),
    );
    expect(result.isOk, isTrue);

    final updated = (await db.select(db.medications).get()).single;
    expect(updated.id, med.id);
    expect(updated.name, 'Sevelamer 400 mg');
    expect(updated.frequencyCode, '1-1-1');
    expect(updated.scheduleGroup, MedScheduleGroup.byClock);
    expect(updated.startDate, DateTime(2026, 8, 1));

    // A correction adds no timeline noise.
    final events = await db.timelineDao.getPage(limit: 10, offset: 0);
    expect(
      events.where((e) => e.type == TimelineEventType.medicationChange),
      hasLength(1),
    );
  });
}
