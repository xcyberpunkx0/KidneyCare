import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/features/dialysis/data/repository_impl/dialysis_repository_impl.dart';
import 'package:recora/features/dialysis/domain/entities/session_log.dart';

void main() {
  late AppDatabase db;
  late DialysisRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DialysisRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> seedPatient() {
    // Mon 7:00 AM and Thu 5:15 PM.
    return db.patientDao.upsert(const PatientsCompanion(
      id: Value('p1'),
      name: Value('Asha'),
      initials: Value('A'),
      age: Value(58),
      conditionSummary: Value('CKD-5'),
      dialysisCenter: Value('City Hospital'),
      dryWeightKg: Value(57.0),
      scheduleJson: Value('{"1":420,"4":1035}'),
    ));
  }

  Future<List<DialysisSession>> allSessions() =>
      db.select(db.dialysisSessions).get();

  test('backdated session keeps its date on history, labs and timeline',
      () async {
    await seedPatient();
    final lastMonday = DateTime(2026, 8, 10);

    final result = await repo.logSession(SessionLog(
      completedAt: lastMonday,
      durationHours: 4,
      postWeightKg: 57.4,
      systolic: 130,
      diastolic: 85,
    ));
    expect(result.isOk, isTrue);

    final history =
        (await allSessions()).where((s) => s.completed).toList();
    expect(history, hasLength(1));
    expect(history.single.scheduledAt, lastMonday);

    final labs = await db.select(db.labResults).get();
    expect(labs, hasLength(3));
    expect(labs.map((l) => l.takenAt), everyElement(lastMonday));

    final events = await db.select(db.timelineEvents).get();
    expect(events.single.occurredAt, lastMonday);
  });

  test('backdated session does not drag the next session into the past',
      () async {
    await seedPatient();

    final result = await repo.logSession(SessionLog(
      completedAt: DateTime(2026, 8, 10),
      durationHours: 4,
    ));
    expect(result.isOk, isTrue);

    final next = (await allSessions())
        .where((s) => !s.completed)
        .single;
    expect(next.scheduledAt.isAfter(DateTime.now()), isTrue,
        reason: 'the standing next session must stay in the future');
  });

  test('session logged now rolls the next session forward as before',
      () async {
    await seedPatient();

    final now = DateTime.now();
    final result =
        await repo.logSession(SessionLog(completedAt: now, durationHours: 4));
    expect(result.isOk, isTrue);

    final next = (await allSessions())
        .where((s) => !s.completed)
        .single;
    expect(next.scheduledAt.isAfter(now), isTrue);
    expect(next.weekday == DateTime.monday || next.weekday == DateTime.thursday,
        isTrue);
  });
}

extension on DialysisSession {
  int get weekday => scheduledAt.weekday;
}
