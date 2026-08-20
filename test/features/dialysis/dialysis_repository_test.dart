import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/features/dialysis/data/repository_impl/dialysis_repository_impl.dart';
import 'package:recora/features/dialysis/domain/entities/session_log.dart';
import 'package:recora/shared/domain/lab_metric.dart';
import 'package:recora/shared/domain/timeline_event_type.dart';

void main() {
  late AppDatabase db;
  late DialysisRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DialysisRepositoryImpl(db);
  });
  tearDown(() => db.close());

  SessionLog log(DateTime at) => SessionLog(
    completedAt: at,
    durationHours: 4,
    preWeightKg: 60.1,
    postWeightKg: 57.4,
    ultrafiltrationL: 2.8,
    systolic: 130,
    diastolic: 80,
    note: 'no cramps',
  );

  test(
    'logSession stores the session, its vitals and a timeline entry',
    () async {
      final at = DateTime(2026, 8, 10);
      final result = await repo.logSession(log(at));
      expect(result.isOk, isTrue);

      final sessions = await db.select(db.dialysisSessions).get();
      expect(sessions.single.completed, isTrue);
      expect(sessions.single.postWeightKg, 57.4);

      final labs = await db.labDao.getAll();
      expect(labs.map((l) => l.metricCode).toSet(), {
        LabMetric.weight.code,
        LabMetric.bloodPressureSystolic.code,
        LabMetric.bloodPressureDiastolic.code,
      });

      final events = await db.timelineDao.getPage(limit: 10, offset: 0);
      expect(events.single.type, TimelineEventType.dialysis);
    },
  );

  test('deleteSession removes the session and everything it recorded, '
      'leaving unrelated rows', () async {
    await repo.logSession(log(DateTime(2026, 8, 10)));
    await repo.logSession(log(DateTime(2026, 8, 13)));

    final sessions = await db.select(db.dialysisSessions).get();
    final target = sessions.firstWhere(
      (s) => s.scheduledAt == DateTime(2026, 8, 10),
    );

    final result = await repo.deleteSession(target.id);
    expect(result.isOk, isTrue);

    final remaining = await db.select(db.dialysisSessions).get();
    expect(remaining.single.scheduledAt, DateTime(2026, 8, 13));

    final labs = await db.labDao.getAll();
    expect(labs, hasLength(3));
    expect(labs.every((l) => l.takenAt == DateTime(2026, 8, 13)), isTrue);

    final events = await db.timelineDao.getPage(limit: 10, offset: 0);
    expect(events.single.occurredAt, DateTime(2026, 8, 13));
  });

  test('updateSession rewrites the session and replaces its vitals', () async {
    await repo.logSession(log(DateTime(2026, 8, 10)));
    final session = (await db.select(db.dialysisSessions).get()).single;

    final result = await repo.updateSession(
      session.id,
      SessionLog(
        completedAt: DateTime(2026, 8, 11),
        durationHours: 3.5,
        postWeightKg: 58.0,
        systolic: 140,
        diastolic: 85,
      ),
    );
    expect(result.isOk, isTrue);

    final updated = (await db.select(db.dialysisSessions).get()).single;
    expect(updated.id, session.id);
    expect(updated.scheduledAt, DateTime(2026, 8, 11));
    expect(updated.durationHours, 3.5);
    expect(updated.preWeightKg, isNull);

    final labs = await db.labDao.getAll();
    expect(labs, hasLength(3));
    expect(labs.every((l) => l.takenAt == DateTime(2026, 8, 11)), isTrue);
    final systolic = labs.firstWhere(
      (l) => l.metricCode == LabMetric.bloodPressureSystolic.code,
    );
    expect(systolic.value, 140);

    final events = await db.timelineDao.getPage(limit: 10, offset: 0);
    expect(events.single.occurredAt, DateTime(2026, 8, 11));
  });

  test('getSessionLog reads BP back from the recorded observations', () async {
    await repo.logSession(log(DateTime(2026, 8, 10)));
    final session = (await db.select(db.dialysisSessions).get()).single;

    final stored = await repo.getSessionLog(session.id);
    expect(stored, isNotNull);
    expect(stored!.systolic, 130);
    expect(stored.diastolic, 80);
    expect(stored.preWeightKg, 60.1);
    expect(stored.note, 'no cramps');
  });
}
