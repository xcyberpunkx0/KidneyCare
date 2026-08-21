import 'package:drift/drift.dart';

import '../../../shared/domain/document_type.dart';
import '../../../shared/domain/med_schedule.dart';
import '../../../shared/domain/timeline_event_type.dart';
import '../app_database.dart';

/// Seeds the vault with a realistic dialysis-patient history so every screen
/// has meaningful content on first launch. Dates are generated relative to
/// now, keeping the record alive no matter when the app is installed.
Future<void> seedDemoData(AppDatabase db) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  await db.patientDao.upsert(
    const PatientsCompanion(
      id: Value('patient-1'),
      name: Value('N. Ramachandran'),
      initials: Value('NR'),
      age: Value(63),
      conditionSummary: Value('CKD-5, HD Mon/Wed/Fri'),
      dialysisCenter: Value('Nephron Centre'),
      dryWeightKg: Value(57.5),
      dryWeightDeltaKg: Value(0.1),
    ),
  );

  await _seedDialysis(db, today);
  await _seedMedications(db, today);
  await _seedDoses(db, today);
  await _seedDocuments(db, today);
  await _seedLabs(db, today);
  await _seedTimeline(db, today);
}

DateTime _daysAgo(DateTime today, int days) =>
    today.subtract(Duration(days: days));

Future<void> _seedDialysis(AppDatabase db, DateTime today) async {
  // Hemodialysis runs Mon/Wed/Fri at 7:00 AM.
  const hdWeekdays = [DateTime.monday, DateTime.wednesday, DateTime.friday];

  DateTime next = today.add(const Duration(days: 1));
  while (!hdWeekdays.contains(next.weekday)) {
    next = next.add(const Duration(days: 1));
  }
  DateTime last = today;
  while (!hdWeekdays.contains(last.weekday)) {
    last = last.subtract(const Duration(days: 1));
  }

  await db.dialysisDao.upsert(
    DialysisSessionsCompanion(
      id: const Value('hd-next'),
      scheduledAt: Value(next.add(const Duration(hours: 7))),
      completed: const Value(false),
      center: const Value('Nephron Centre'),
    ),
  );
  await db.dialysisDao.upsert(
    DialysisSessionsCompanion(
      id: const Value('hd-last'),
      scheduledAt: Value(last.add(const Duration(hours: 7))),
      completed: const Value(true),
      center: const Value('Nephron Centre'),
      ultrafiltrationL: const Value(2.8),
      preWeightKg: const Value(60.1),
      postWeightKg: const Value(57.4),
      note: const Value('no cramps'),
    ),
  );
}

Future<void> _seedMedications(AppDatabase db, DateTime today) async {
  final meds = [
    MedicationsCompanion(
      id: const Value('med-sevelamer'),
      name: const Value('Sevelamer 400 mg'),
      dose: const Value('400 mg'),
      frequencyCode: const Value('1-1-1'),
      purpose: const Value('Phosphate binder'),
      doctor: const Value('Dr. Menon'),
      foodRelation: const Value(MedFoodRelation.withFood),
      scheduleNote: const Value('with every meal'),
      startDate: Value(_daysAgo(today, 240)),
    ),
    MedicationsCompanion(
      id: const Value('med-calcium'),
      name: const Value('Calcium acetate 667 mg'),
      dose: const Value('667 mg'),
      frequencyCode: const Value('1-0-1'),
      purpose: const Value('Phosphate binder'),
      doctor: const Value('Dr. Menon'),
      foodRelation: const Value(MedFoodRelation.withFood),
      scheduleNote: const Value('breakfast & dinner'),
      startDate: Value(_daysAgo(today, 180)),
    ),
    MedicationsCompanion(
      id: const Value('med-torsemide'),
      name: const Value('Torsemide 20 mg'),
      dose: const Value('20 mg'),
      frequencyCode: const Value('1-0-0'),
      purpose: const Value('Diuretic'),
      doctor: const Value('Dr. Menon'),
      timeOfDayJson: const Value('["morning"]'),
      scheduleNote: const Value('morning'),
      startDate: Value(_daysAgo(today, 320)),
    ),
    MedicationsCompanion(
      id: const Value('med-amlodipine'),
      name: const Value('Amlodipine 10 mg'),
      dose: const Value('10 mg'),
      frequencyCode: const Value('0-0-1'),
      purpose: const Value('Blood pressure'),
      doctor: const Value('Dr. Iyer'),
      timeOfDayJson: const Value('["night"]'),
      scheduleNote: const Value('at night'),
      startDate: Value(_daysAgo(today, 400)),
    ),
    MedicationsCompanion(
      id: const Value('med-wepox'),
      name: const Value('Wepox 10,000 IU'),
      dose: const Value('10,000 IU'),
      frequencyCode: const Value('weekly'),
      purpose: const Value('Erythropoietin'),
      doctor: const Value('Dr. Menon'),
      frequency: const Value(MedFrequency.dialysisDaysOnly),
      scheduleNote: const Value('s/c after dialysis, weekly'),
      startDate: Value(_daysAgo(today, 150)),
      changeNote: const Value('dose ↑'),
      changeDate: Value(_daysAgo(today, 9)),
    ),
    MedicationsCompanion(
      id: const Value('med-iron'),
      name: const Value('Ferrous ascorbate 100 mg'),
      dose: const Value('100 mg'),
      frequencyCode: const Value('1-0-0'),
      purpose: const Value('Iron supplement'),
      doctor: const Value('Dr. Menon'),
      foodRelation: const Value(MedFoodRelation.beforeFood),
      timeOfDayJson: const Value('["morning"]'),
      scheduleNote: const Value('empty stomach'),
      startDate: Value(_daysAgo(today, 150)),
    ),
    MedicationsCompanion(
      id: const Value('med-shelcal'),
      name: const Value('Shelcal 500 mg'),
      dose: const Value('500 mg'),
      frequencyCode: const Value('0-1-0'),
      purpose: const Value('Calcium supplement'),
      doctor: const Value('Dr. Menon'),
      foodRelation: const Value(MedFoodRelation.withFood),
      scheduleNote: const Value('after lunch'),
      startDate: Value(_daysAgo(today, 90)),
    ),
    MedicationsCompanion(
      id: const Value('med-febuxostat'),
      name: const Value('Febuxostat 40 mg'),
      dose: const Value('40 mg'),
      frequencyCode: const Value('1-0-0'),
      purpose: const Value('Uric acid'),
      doctor: const Value('Dr. Iyer'),
      timeOfDayJson: const Value('["morning"]'),
      scheduleNote: const Value('morning'),
      startDate: Value(_daysAgo(today, 200)),
    ),
    MedicationsCompanion(
      id: const Value('med-b12'),
      name: const Value('Methylcobalamin 1500 mcg'),
      dose: const Value('1500 mcg'),
      frequencyCode: const Value('1-0-0'),
      purpose: const Value('Vitamin B12'),
      doctor: const Value('Dr. Menon'),
      timeOfDayJson: const Value('["morning"]'),
      scheduleNote: const Value('morning'),
      startDate: Value(_daysAgo(today, 100)),
    ),
    // Ended medicines.
    MedicationsCompanion(
      id: const Value('med-cefixime'),
      name: const Value('Cefixime 200 mg'),
      dose: const Value('200 mg'),
      frequencyCode: const Value('1-0-1'),
      purpose: const Value('Antibiotic — catheter site infection'),
      doctor: const Value('Dr. Prakash'),
      scheduleNote: const Value('7-day course'),
      startDate: Value(_daysAgo(today, 62)),
      endDate: Value(_daysAgo(today, 55)),
    ),
    MedicationsCompanion(
      id: const Value('med-nifedipine'),
      name: const Value('Nifedipine 10 mg'),
      dose: const Value('10 mg'),
      frequencyCode: const Value('1-0-1'),
      purpose: const Value('Blood pressure — replaced by amlodipine'),
      doctor: const Value('Dr. Iyer'),
      scheduleNote: const Value(''),
      startDate: Value(_daysAgo(today, 500)),
      endDate: Value(_daysAgo(today, 400)),
    ),
  ];
  for (final med in meds) {
    await db.medicationDao.upsert(med);
  }
}

Future<void> _seedDoses(AppDatabase db, DateTime today) async {
  await db.doseDao.insertAll([
    DosesCompanion(
      id: const Value('dose-1'),
      medicationId: const Value('med-torsemide'),
      medicationLabel: const Value('Torsemide 20'),
      timeLabel: const Value('7 AM'),
      sortOrder: const Value(0),
      scheduledOn: Value(today),
      taken: const Value(true),
    ),
    DosesCompanion(
      id: const Value('dose-2'),
      medicationId: const Value('med-sevelamer'),
      medicationLabel: const Value('Sevelamer 400'),
      timeLabel: const Value('8 AM'),
      sortOrder: const Value(1),
      scheduledOn: Value(today),
      taken: const Value(true),
    ),
    DosesCompanion(
      id: const Value('dose-3'),
      medicationId: const Value('med-sevelamer'),
      medicationLabel: const Value('Sevelamer 400'),
      timeLabel: const Value('1 PM'),
      sortOrder: const Value(2),
      scheduledOn: Value(today),
    ),
    DosesCompanion(
      id: const Value('dose-4'),
      medicationId: const Value('med-sevelamer'),
      medicationLabel: const Value('Sevelamer 400'),
      timeLabel: const Value('8 PM'),
      sortOrder: const Value(3),
      scheduledOn: Value(today),
    ),
    DosesCompanion(
      id: const Value('dose-5'),
      medicationId: const Value('med-amlodipine'),
      medicationLabel: const Value('Amlodipine 10'),
      timeLabel: const Value('9 PM'),
      sortOrder: const Value(4),
      scheduledOn: Value(today),
    ),
  ]);
}

Future<void> _seedDocuments(AppDatabase db, DateTime today) async {
  final docs = <DocumentsCompanion>[
    DocumentsCompanion(
      id: const Value('doc-panel-aug'),
      type: const Value(DocumentType.labReport),
      title: const Value('Monthly blood panel'),
      hospital: const Value('Apex Diagnostics'),
      doctor: const Value('Dr. Menon'),
      documentDate: Value(_daysAgo(today, 4)),
      capturedAt: Value(_daysAgo(today, 4)),
      tagsJson: const Value('["CBC","Renal profile"]'),
      ocrText: const Value(
          'Hemoglobin 9.4 g/dL, Potassium 5.3 mmol/L, Creatinine 8.2 mg/dL, '
          'Phosphorus 5.1 mg/dL, Albumin 3.4 g/dL, Calcium 8.9 mg/dL'),
    ),
    DocumentsCompanion(
      id: const Value('doc-epo-rx'),
      type: const Value(DocumentType.prescription),
      title: const Value('EPO raised to 10,000 IU/wk'),
      hospital: const Value('Nephron Centre'),
      doctor: const Value('Dr. Menon'),
      documentDate: Value(_daysAgo(today, 9)),
      capturedAt: Value(_daysAgo(today, 9)),
      tagsJson: const Value('["Erythropoietin","Anemia"]'),
      ocrText: const Value(
          'Inj. Wepox 10000 IU s/c once weekly after dialysis. '
          'Continue iron supplementation.'),
    ),
    DocumentsCompanion(
      id: const Value('doc-hd-log'),
      type: const Value(DocumentType.scan),
      title: const Value('Dialysis session record'),
      hospital: const Value('Nephron Centre'),
      doctor: const Value('Dr. Prakash'),
      documentDate: Value(_daysAgo(today, 10)),
      capturedAt: Value(_daysAgo(today, 10)),
      tagsJson: const Value('["Hemodialysis"]'),
      ocrText: const Value('4 h session, UF 2.8 L, pre 60.1 kg, post 57.4 kg, '
          'no intradialytic events'),
    ),
    DocumentsCompanion(
      id: const Value('doc-discharge-jun'),
      type: const Value(DocumentType.dischargeSummary),
      title: const Value('Discharge summary — fluid overload'),
      hospital: const Value('St. Mary\'s Hospital'),
      doctor: const Value('Dr. Prakash'),
      documentDate: Value(_daysAgo(today, 55)),
      capturedAt: Value(_daysAgo(today, 54)),
      tagsJson: const Value('["Admission","Fluid overload"]'),
      ocrText: const Value(
          'Admitted with dyspnea and pedal edema. Managed with additional '
          'ultrafiltration sessions. Cefixime 200 mg BD for catheter site '
          'infection. Discharged stable.'),
    ),
    DocumentsCompanion(
      id: const Value('doc-bill-jun'),
      type: const Value(DocumentType.bill),
      title: const Value('Inpatient bill — June admission'),
      hospital: const Value('St. Mary\'s Hospital'),
      doctor: const Value(''),
      documentDate: Value(_daysAgo(today, 55)),
      capturedAt: Value(_daysAgo(today, 53)),
      tagsJson: const Value('["Insurance"]'),
      ocrText: const Value('Room charges, dialysis sessions x4, pharmacy, '
          'total ₹86,400'),
    ),
    DocumentsCompanion(
      id: const Value('doc-panel-jul'),
      type: const Value(DocumentType.labReport),
      title: const Value('Monthly blood panel'),
      hospital: const Value('Apex Diagnostics'),
      doctor: const Value('Dr. Menon'),
      documentDate: Value(_daysAgo(today, 34)),
      capturedAt: Value(_daysAgo(today, 34)),
      tagsJson: const Value('["CBC","Renal profile"]'),
      ocrText: const Value(
          'Hemoglobin 9.8 g/dL, Potassium 4.9 mmol/L, Creatinine 8.4 mg/dL'),
    ),
    DocumentsCompanion(
      id: const Value('doc-fistula'),
      type: const Value(DocumentType.scan),
      title: const Value('AV fistula doppler study'),
      hospital: const Value('Apex Diagnostics'),
      doctor: const Value('Dr. Rao'),
      documentDate: Value(_daysAgo(today, 75)),
      capturedAt: Value(_daysAgo(today, 74)),
      tagsJson: const Value('["Vascular access"]'),
      ocrText: const Value('Left radiocephalic fistula, flow 820 mL/min, '
          'no stenosis'),
    ),
    DocumentsCompanion(
      id: const Value('doc-note-diet'),
      type: const Value(DocumentType.handwrittenNote),
      title: const Value('Dietitian instructions'),
      hospital: const Value('Nephron Centre'),
      doctor: const Value('Ms. Kavitha'),
      documentDate: Value(_daysAgo(today, 2)),
      capturedAt: Value(_daysAgo(today, 2)),
      tagsJson: const Value('["Diet","Potassium"]'),
      ocrText: const Value('Low potassium diet until Wednesday. Avoid banana, '
          'coconut water, tomato. Restrict fluid to 1 L/day.'),
    ),
  ];
  for (final doc in docs) {
    await db.documentDao.upsert(doc);
  }
}

Future<void> _seedLabs(AppDatabase db, DateTime today) async {
  // Six monthly panels; the recent Hb trend falls while K creeps up,
  // matching the "needs attention" story on the home screen.
  const hb = [10.8, 10.9, 10.4, 10.1, 9.8, 9.4];
  const k = [4.4, 4.2, 4.6, 4.8, 4.9, 5.3];
  const cr = [7.8, 8.1, 7.9, 8.6, 8.4, 8.2];
  const alb = [3.7, 3.6, 3.6, 3.5, 3.5, 3.4];
  const phos = [4.8, 5.4, 4.9, 4.6, 5.2, 5.1];
  const ca = [9.1, 8.8, 9.0, 8.7, 8.9, 8.9];
  const wt = [58.4, 58.1, 57.9, 57.6, 57.4, 57.5];
  const bps = [142.0, 138.0, 144.0, 136.0, 140.0, 138.0];
  const bpd = [88.0, 84.0, 90.0, 82.0, 86.0, 86.0];

  final entries = <LabResultsCompanion>[];
  final series = {
    'hb': hb, 'k': k, 'cr': cr, 'alb': alb, 'phos': phos,
    'ca': ca, 'wt': wt, 'bps': bps, 'bpd': bpd,
  };
  series.forEach((code, values) {
    for (var i = 0; i < values.length; i++) {
      final monthsBack = values.length - 1 - i;
      final takenAt = DateTime(today.year, today.month - monthsBack,
          monthsBack == 0 ? today.day - 4 : 2);
      entries.add(LabResultsCompanion(
        id: Value('lab-$code-$i'),
        metricCode: Value(code),
        value: Value(values[i].toDouble()),
        takenAt: Value(takenAt),
        documentId: Value(monthsBack == 0 ? 'doc-panel-aug' : null),
      ));
    }
  });
  await db.labDao.insertAll(entries);
}

Future<void> _seedTimeline(AppDatabase db, DateTime today) async {
  final events = <TimelineEventsCompanion>[
    TimelineEventsCompanion(
      id: const Value('tl-panel-aug'),
      type: const Value(TimelineEventType.labReport),
      title: const Value('Monthly blood panel'),
      subtitle: const Value('Apex Diagnostics · 2 values off'),
      occurredAt: Value(_daysAgo(today, 4)),
      documentId: const Value('doc-panel-aug'),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-epo'),
      type: const Value(TimelineEventType.medicationChange),
      title: const Value('EPO raised to 10,000 IU/wk'),
      subtitle: const Value('Prescription · Dr. Menon'),
      occurredAt: Value(_daysAgo(today, 9)),
      documentId: const Value('doc-epo-rx'),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-hd'),
      type: const Value(TimelineEventType.dialysis),
      title: const Value('Dialysis session · 4 h'),
      subtitle: const Value('UF 2.8 L · 60.1 → 57.4 kg'),
      occurredAt: Value(_daysAgo(today, 10)),
      documentId: const Value('doc-hd-log'),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-visit-jul'),
      type: const Value(TimelineEventType.doctorVisit),
      title: const Value('Nephrology review'),
      subtitle: const Value('Dr. Menon · continue current plan'),
      occurredAt: Value(_daysAgo(today, 34)),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-panel-jul'),
      type: const Value(TimelineEventType.labReport),
      title: const Value('Monthly blood panel'),
      subtitle: const Value('Apex Diagnostics · all stable'),
      occurredAt: Value(_daysAgo(today, 34)),
      documentId: const Value('doc-panel-jul'),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-discharge'),
      type: const Value(TimelineEventType.discharge),
      title: const Value('Discharged — fluid overload'),
      subtitle: const Value('St. Mary\'s Hospital · 5-day stay'),
      occurredAt: Value(_daysAgo(today, 55)),
      documentId: const Value('doc-discharge-jun'),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-bill'),
      type: const Value(TimelineEventType.bill),
      title: const Value('Inpatient bill settled'),
      subtitle: const Value('St. Mary\'s Hospital · ₹86,400'),
      occurredAt: Value(_daysAgo(today, 53)),
      documentId: const Value('doc-bill-jun'),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-admission'),
      type: const Value(TimelineEventType.admission),
      title: const Value('Admitted — breathlessness'),
      subtitle: const Value('St. Mary\'s Hospital · Dr. Prakash'),
      occurredAt: Value(_daysAgo(today, 60)),
    ),
    TimelineEventsCompanion(
      id: const Value('tl-fistula'),
      type: const Value(TimelineEventType.procedure),
      title: const Value('AV fistula doppler study'),
      subtitle: const Value('Flow 820 mL/min · no stenosis'),
      occurredAt: Value(_daysAgo(today, 75)),
      documentId: const Value('doc-fistula'),
    ),
  ];
  for (final event in events) {
    await db.timelineDao.insert(event);
  }
}
