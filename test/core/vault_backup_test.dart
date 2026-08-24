import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/services/vault_export.dart';
import 'package:recora/core/services/vault_restore.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/utils/app_failure.dart';
import 'package:recora/shared/domain/claim_status.dart';
import 'package:recora/shared/domain/document_type.dart';
import 'package:recora/shared/domain/med_schedule.dart';
import 'package:recora/shared/domain/timeline_event_type.dart';

void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() {
    source = AppDatabase.forTesting(NativeDatabase.memory());
    target = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  /// Fills [db] with one row (or a few) in every table the backup carries,
  /// touching every column so a round-trip that drops a field is caught.
  Future<void> populate(AppDatabase db) async {
    await db.patientDao.upsert(
      const PatientsCompanion(
        id: Value('p1'),
        name: Value('Ramesh Gupta'),
        initials: Value('RG'),
        age: Value(64),
        conditionSummary: Value('ESRD on MHD'),
        dialysisCenter: Value('City Hospital'),
        dryWeightKg: Value(57.5),
        dryWeightDeltaKg: Value(0.5),
        scheduleJson: Value('{"1":420,"4":1035}'),
        bloodGroup: Value('B+'),
        allergies: Value('Penicillin'),
        emergencyContact: Value('Sunita 98765 43210'),
        comorbidities: Value('Diabetes, Hypertension'),
      ),
    );
    await db.documentDao.upsert(
      DocumentsCompanion(
        id: const Value('d1'),
        type: const Value(DocumentType.labReport),
        title: const Value('CBC report'),
        hospital: const Value('City Hospital'),
        doctor: const Value('Dr Rao'),
        documentDate: Value(DateTime(2026, 8, 1)),
        capturedAt: Value(DateTime(2026, 8, 2, 10, 30)),
        originalPath: const Value('/scans/d1.jpg'),
        previewPath: const Value('/previews/d1.jpg'),
        ocrText: const Value('Hb 10.2'),
        tagsJson: const Value('["cbc","monthly"]'),
        note: const Value('Fasting sample'),
      ),
    );
    await db.documentDao.upsert(
      DocumentsCompanion(
        id: const Value('d2'),
        type: const Value(DocumentType.bill),
        title: const Value('Dialysis bill'),
        documentDate: Value(DateTime(2026, 8, 5)),
        capturedAt: Value(DateTime(2026, 8, 5)),
      ),
    );
    await db.documentDao.insertPages([
      const DocumentPagesCompanion(
        id: Value('pg1'),
        documentId: Value('d1'),
        pageIndex: Value(0),
        originalPath: Value('/scans/d1.jpg'),
      ),
      const DocumentPagesCompanion(
        id: Value('pg2'),
        documentId: Value('d1'),
        pageIndex: Value(1),
        originalPath: Value('/scans/d1-2.jpg'),
      ),
    ]);
    await db.medicationDao.upsert(
      MedicationsCompanion(
        id: const Value('m1'),
        name: const Value('Sevelamer'),
        dose: const Value('400 mg'),
        frequencyCode: const Value('tid'),
        purpose: const Value('Phosphate binder'),
        doctor: const Value('Dr Rao'),
        foodRelation: const Value(MedFoodRelation.withFood),
        timeOfDayJson: const Value('["morning","night"]'),
        frequency: const Value(MedFrequency.daily),
        scheduleNote: const Value('With meals'),
        startDate: Value(DateTime(2026, 1, 10)),
        changeNote: const Value('Dose raised'),
        changeDate: Value(DateTime(2026, 3, 1)),
        sourceDocumentId: const Value('d1'),
      ),
    );
    await db.medicationDao.upsert(
      MedicationsCompanion(
        id: const Value('m2'),
        name: const Value('Erythropoietin'),
        dose: const Value('4000 IU'),
        frequencyCode: const Value('q3d'),
        purpose: const Value('Anemia'),
        frequency: const Value(MedFrequency.everyNDays),
        intervalDays: const Value(3),
        lastGivenOn: Value(DateTime(2026, 8, 20)),
        startDate: Value(DateTime(2025, 11, 1)),
        endDate: Value(DateTime(2026, 6, 1)),
      ),
    );
    await db.labDao.insertAll([
      LabResultsCompanion(
        id: const Value('l1'),
        metricCode: const Value('hb'),
        value: const Value(10.2),
        takenAt: Value(DateTime(2026, 8, 1)),
        documentId: const Value('d1'),
      ),
      LabResultsCompanion(
        id: const Value('l2'),
        metricCode: const Value('k'),
        value: const Value(4.8),
        takenAt: Value(DateTime(2026, 8, 1)),
      ),
    ]);
    await db.timelineDao.insert(
      TimelineEventsCompanion(
        id: const Value('t1'),
        type: const Value(TimelineEventType.labReport),
        title: const Value('CBC report'),
        subtitle: const Value('City Hospital'),
        occurredAt: Value(DateTime(2026, 8, 1)),
        documentId: const Value('d1'),
      ),
    );
    await db.dialysisDao.upsert(
      DialysisSessionsCompanion(
        id: const Value('s1'),
        scheduledAt: Value(DateTime(2026, 8, 21, 7)),
        completed: const Value(true),
        center: const Value('City Hospital'),
        ultrafiltrationL: const Value(2.5),
        preWeightKg: const Value(60),
        postWeightKg: const Value(57.5),
        durationHours: const Value(4),
        note: const Value('Cramps near the end'),
      ),
    );
    await db.claimDao.upsertPolicy(
      const InsurancePoliciesCompanion(
        id: Value('pol1'),
        insurerName: Value('Star Health'),
        policyNumber: Value('SH-123'),
        tpaName: Value('MediAssist'),
        claimWindowDays: Value(45),
        note: Value('Top-up'),
      ),
    );
    await db.claimDao.upsertClaim(
      ClaimsCompanion(
        id: const Value('c1'),
        policyId: const Value('pol1'),
        title: const Value('August dialysis'),
        status: const Value(ClaimStatus.submitted),
        createdAt: Value(DateTime(2026, 8, 6)),
        submittedOn: Value(DateTime(2026, 8, 8)),
        claimedAmountPaise: const Value(1250000),
        insurerRef: const Value('CLM-9'),
        note: const Value('Sent by courier'),
      ),
    );
    await db.claimDao.attachDocument('c1', 'd2');
    await db.claimDao.upsertChecklistItem(
      const ClaimChecklistItemsCompanion(
        id: Value('ck1'),
        claimId: Value('c1'),
        label: Value('Original bills'),
        isDone: Value(true),
        sortOrder: Value(1),
      ),
    );
  }

  Future<List<D>> rows<T extends Table, D>(
    AppDatabase db,
    TableInfo<T, D> table,
  ) {
    return (db.select(table)..orderBy([
          for (final column in table.$primaryKey)
            (_) => OrderingTerm.asc(column),
        ]))
        .get();
  }

  Future<void> expectSameVault(AppDatabase a, AppDatabase b) async {
    expect(await rows(b, b.patients), await rows(a, a.patients));
    expect(await rows(b, b.documents), await rows(a, a.documents));
    expect(await rows(b, b.documentPages), await rows(a, a.documentPages));
    expect(await rows(b, b.medications), await rows(a, a.medications));
    expect(await rows(b, b.labResults), await rows(a, a.labResults));
    expect(await rows(b, b.timelineEvents), await rows(a, a.timelineEvents));
    expect(
      await rows(b, b.dialysisSessions),
      await rows(a, a.dialysisSessions),
    );
    expect(
      await rows(b, b.insurancePolicies),
      await rows(a, a.insurancePolicies),
    );
    expect(await rows(b, b.claims), await rows(a, a.claims));
    expect(await rows(b, b.claimDocuments), await rows(a, a.claimDocuments));
    expect(
      await rows(b, b.claimChecklistItems),
      await rows(a, a.claimChecklistItems),
    );
  }

  group('format 2 round trip', () {
    test('restoring an export reproduces every row of every table', () async {
      await populate(source);
      final json = jsonEncode(await VaultExport(source).buildBackup());

      final summary = await VaultRestore(target).restoreFromJson(json);

      await expectSameVault(source, target);
      expect(summary.medications, 2);
      expect(summary.documents, 2);
      expect(summary.labResults, 2);
      expect(summary.timelineEvents, 1);
      expect(summary.dialysisSessions, 1);
      expect(summary.claims, 1);
    });

    test('restore replaces whatever the device already holds', () async {
      await populate(source);
      await target.medicationDao.upsert(
        MedicationsCompanion(
          id: const Value('stale'),
          name: const Value('Old medicine'),
          dose: const Value(''),
          frequencyCode: const Value('od'),
          purpose: const Value(''),
          startDate: Value(DateTime(2024, 1, 1)),
        ),
      );
      await target.chatDao.insert(
        ChatMessagesCompanion(
          id: const Value('chat1'),
          role: const Value('user'),
          content: const Value('hello'),
          createdAt: Value(DateTime(2026, 8, 1)),
        ),
      );
      final json = jsonEncode(await VaultExport(source).buildBackup());

      await VaultRestore(target).restoreFromJson(json);

      await expectSameVault(source, target);
      expect(await rows(target, target.chatMessages), isEmpty);
    });

    test('an empty vault exports and restores cleanly', () async {
      final json = jsonEncode(await VaultExport(source).buildBackup());
      final summary = await VaultRestore(target).restoreFromJson(json);
      await expectSameVault(source, target);
      expect(summary.medications, 0);
    });
  });

  group('format 1 (pre-restore exports)', () {
    const legacy = '''
{
  "app": "KidneyCare",
  "exportedAt": "2026-08-20T10:00:00.000",
  "patient": {
    "name": "Ramesh Gupta",
    "age": 64,
    "condition": "ESRD on MHD",
    "center": "City Hospital",
    "dryWeightKg": 57.5
  },
  "medications": [
    {
      "name": "Sevelamer",
      "dose": "400 mg",
      "frequency": "tid",
      "purpose": "Phosphate binder",
      "doctor": "Dr Rao",
      "schedule": "With meals",
      "startDate": "2026-01-10T00:00:00.000",
      "endDate": null
    },
    {
      "name": "Erythropoietin",
      "dose": "4000 IU",
      "frequency": "q3d",
      "purpose": "Anemia",
      "doctor": "",
      "schedule": "",
      "startDate": "2025-11-01T00:00:00.000",
      "endDate": "2026-06-01T00:00:00.000"
    }
  ],
  "labResults": [
    {"metric": "hb", "value": 10.2, "takenAt": "2026-08-01T00:00:00.000"}
  ],
  "documents": [
    {
      "type": "labReport",
      "title": "CBC report",
      "hospital": "City Hospital",
      "doctor": "Dr Rao",
      "date": "2026-08-01T00:00:00.000",
      "tags": ["cbc", "monthly"],
      "extractedText": "Hb 10.2"
    }
  ],
  "timeline": [
    {
      "type": "labReport",
      "title": "CBC report",
      "subtitle": "City Hospital",
      "date": "2026-08-01T00:00:00.000"
    }
  ]
}
''';

    test('restores the structured record with fresh ids', () async {
      final summary = await VaultRestore(target).restoreFromJson(legacy);

      final patient = await target.patientDao.getPatient();
      expect(patient, isNotNull);
      expect(patient!.name, 'Ramesh Gupta');
      expect(patient.initials, 'RG');
      expect(patient.age, 64);
      expect(patient.conditionSummary, 'ESRD on MHD');
      expect(patient.dialysisCenter, 'City Hospital');
      expect(patient.dryWeightKg, 57.5);

      final meds = await rows(target, target.medications);
      expect(meds, hasLength(2));
      final sevelamer = meds.singleWhere((m) => m.name == 'Sevelamer');
      expect(sevelamer.id, isNotEmpty);
      expect(sevelamer.dose, '400 mg');
      expect(sevelamer.frequencyCode, 'tid');
      expect(sevelamer.purpose, 'Phosphate binder');
      expect(sevelamer.doctor, 'Dr Rao');
      expect(sevelamer.scheduleNote, 'With meals');
      expect(sevelamer.startDate, DateTime(2026, 1, 10));
      expect(sevelamer.endDate, isNull);
      final epo = meds.singleWhere((m) => m.name == 'Erythropoietin');
      expect(epo.endDate, DateTime(2026, 6, 1));
      expect(meds.map((m) => m.id).toSet(), hasLength(2));

      final labs = await target.labDao.getAll();
      expect(labs, hasLength(1));
      expect(labs.single.metricCode, 'hb');
      expect(labs.single.value, 10.2);
      expect(labs.single.takenAt, DateTime(2026, 8, 1));

      final docs = await target.documentDao.watchAll().first;
      expect(docs, hasLength(1));
      expect(docs.single.type, DocumentType.labReport);
      expect(docs.single.title, 'CBC report');
      expect(docs.single.hospital, 'City Hospital');
      expect(docs.single.doctor, 'Dr Rao');
      expect(docs.single.documentDate, DateTime(2026, 8, 1));
      expect(jsonDecode(docs.single.tagsJson), ['cbc', 'monthly']);
      expect(docs.single.ocrText, 'Hb 10.2');

      final events = await target.timelineDao.getPage(limit: 10, offset: 0);
      expect(events, hasLength(1));
      expect(events.single.type, TimelineEventType.labReport);
      expect(events.single.title, 'CBC report');
      expect(events.single.subtitle, 'City Hospital');
      expect(events.single.occurredAt, DateTime(2026, 8, 1));

      expect(summary.medications, 2);
      expect(summary.documents, 1);
      expect(summary.labResults, 1);
      expect(summary.timelineEvents, 1);
      expect(summary.dialysisSessions, 0);
      expect(summary.claims, 0);
    });

    test('a null patient leaves the patient table empty', () async {
      final json = jsonEncode({
        'app': 'KidneyCare',
        'patient': null,
        'medications': <Object>[],
        'labResults': <Object>[],
        'documents': <Object>[],
        'timeline': <Object>[],
      });
      await VaultRestore(target).restoreFromJson(json);
      expect(await target.patientDao.getPatient(), isNull);
    });
  });

  group('rejects bad input', () {
    test('a file that is not JSON', () async {
      await expectLater(
        VaultRestore(target).restoreFromJson('not json at all'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('JSON that is not a KidneyCare backup', () async {
      await expectLater(
        VaultRestore(target).restoreFromJson('{"hello": "world"}'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('a newer format than this build understands', () async {
      await expectLater(
        VaultRestore(
          target,
        ).restoreFromJson('{"app": "KidneyCare", "format": 99}'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('a corrupt row rolls the whole restore back', () async {
      await populate(target);
      final before = await rows(target, target.medications);
      final backup = await VaultExport(source).buildBackup();
      backup['documents'] = [
        {'id': 'x', 'type': 'notAType', 'title': 'Bad', 'date': 'nope'},
      ];

      await expectLater(
        VaultRestore(target).restoreFromJson(jsonEncode(backup)),
        throwsA(isA<AppFailure>()),
      );

      expect(await rows(target, target.medications), before);
    });
  });
}
