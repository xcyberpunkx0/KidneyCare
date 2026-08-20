import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/features/medications/data/repository_impl/medications_repository_impl.dart';
import 'package:recora/features/medications/domain/entities/new_medication.dart';
import 'package:recora/features/medications/domain/usecases/interval_due.dart';
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

  NewMedication entry(String name, {int? intervalDays}) => NewMedication(
    name: name,
    frequencyCode: '1-0-1',
    purpose: 'Phosphate binder',
    doctor: 'Dr. Rao',
    scheduleGroup: intervalDays == null
        ? MedScheduleGroup.withFood
        : MedScheduleGroup.weekly,
    timingCues: const {MedTimingCue.withFood},
    scheduleNote: '',
    startDate: DateTime(2026, 8, 1),
    intervalDays: intervalDays,
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

  test(
    'an interval medicine is due until marked given, then rolls forward',
    () async {
      await repo.addManual(entry('EPO 10000 IU', intervalDays: 7));
      var med = (await db.select(db.medications).get()).single;
      expect(med.intervalDays, 7);

      // Never given: due today, next due today.
      final today = DateTime(2026, 8, 20);
      expect(med.isDueOn(today), isTrue);
      expect(med.nextDueOn(today), DateTime(2026, 8, 20));

      // Marking given (time of day irrelevant) stamps the day and records it.
      final result = await repo.markGiven(
        med.id,
        DateTime(2026, 8, 20, 14, 30),
      );
      expect(result.isOk, isTrue);
      med = (await db.select(db.medications).get()).single;
      expect(med.lastGivenOn, DateTime(2026, 8, 20));
      expect(med.wasGivenOn(today), isTrue);
      expect(med.isDueOn(today), isFalse);
      expect(med.nextDueOn(today), DateTime(2026, 8, 27));
      expect(med.overdueDaysOn(DateTime(2026, 8, 29)), 2);

      final events = await db.timelineDao.getPage(limit: 10, offset: 0);
      expect(events.first.title, 'Given EPO 10000 IU');
      expect(events.first.occurredAt, DateTime(2026, 8, 20));
    },
  );

  test('undoGiven the same day restores the previous given day', () async {
    await repo.addManual(entry('EPO 10000 IU', intervalDays: 7));
    final id = (await db.select(db.medications).get()).single.id;
    await repo.markGiven(id, DateTime(2026, 8, 13));
    await repo.markGiven(id, DateTime(2026, 8, 20));

    // Undo on a day it was not marked given does nothing.
    await repo.undoGiven(id, DateTime(2026, 8, 19));
    var med = (await db.select(db.medications).get()).single;
    expect(med.lastGivenOn, DateTime(2026, 8, 20));

    await repo.undoGiven(id, DateTime(2026, 8, 20));
    med = (await db.select(db.medications).get()).single;
    expect(med.lastGivenOn, DateTime(2026, 8, 13));

    final given = (await db.timelineDao.getPage(
      limit: 10,
      offset: 0,
    )).where((e) => e.title == 'Given EPO 10000 IU');
    expect(given.single.occurredAt, DateTime(2026, 8, 13));
  });

  test('deleteMedication also removes its Given timeline entries', () async {
    await repo.addManual(entry('EPO 10000 IU', intervalDays: 7));
    final id = (await db.select(db.medications).get()).single.id;
    await repo.markGiven(id, DateTime(2026, 8, 13));
    await repo.markGiven(id, DateTime(2026, 8, 20));

    await repo.deleteMedication(id);

    expect(await db.select(db.medications).get(), isEmpty);
    expect(await db.timelineDao.getPage(limit: 10, offset: 0), isEmpty);
  });
}
