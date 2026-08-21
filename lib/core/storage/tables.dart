import 'package:drift/drift.dart';

import '../../shared/domain/claim_status.dart';
import '../../shared/domain/document_type.dart';
import '../../shared/domain/med_schedule.dart';
import '../../shared/domain/timeline_event_type.dart';

/// The single patient this vault tracks.
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get initials => text()();
  IntColumn get age => integer()();
  TextColumn get conditionSummary => text()();
  TextColumn get dialysisCenter => text()();
  RealColumn get dryWeightKg => real()();
  RealColumn get dryWeightDeltaKg => real().withDefault(const Constant(0))();

  /// Dialysis schedule as JSON: weekday (1=Mon..7=Sun) → start time in
  /// minutes past midnight, e.g. {"1":420,"4":1035} for Mon 7:00 AM and
  /// Thu 5:15 PM.
  TextColumn get scheduleJson => text().withDefault(const Constant('{}'))();

  /// Emergency-card details.
  TextColumn get bloodGroup => text().withDefault(const Constant(''))();
  TextColumn get allergies => text().withDefault(const Constant(''))();
  TextColumn get emergencyContact => text().withDefault(const Constant(''))();

  /// Comma-separated other conditions, e.g.
  /// "Diabetes, Hypertension, Chronic pancreatitis". Kept in English so
  /// emergency staff and reports read them unambiguously.
  TextColumn get comorbidities => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Metadata for a captured document. Original scans stay untouched on disk;
/// only paths and extracted metadata live here.
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<DocumentType>()();
  TextColumn get title => text()();
  TextColumn get hospital => text().withDefault(const Constant(''))();
  TextColumn get doctor => text().withDefault(const Constant(''))();
  DateTimeColumn get documentDate => dateTime()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get originalPath => text().withDefault(const Constant(''))();
  TextColumn get previewPath => text().withDefault(const Constant(''))();
  TextColumn get ocrText => text().withDefault(const Constant(''))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Ordered page images of a multi-page document (photographed page by
/// page or imported from a PDF). Documents captured as a single image
/// have no rows here — Documents.originalPath is the fallback, and it
/// always mirrors page 0 for documents that do have rows.
class DocumentPages extends Table {
  TextColumn get id => text()();
  TextColumn get documentId => text()();

  /// 0-based position within the document, in pick/page order.
  IntColumn get pageIndex => integer()();
  TextColumn get originalPath => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get dose => text()();
  TextColumn get frequencyCode => text()();
  TextColumn get purpose => text()();
  TextColumn get doctor => text().withDefault(const Constant(''))();
  TextColumn get foodRelation => textEnum<MedFoodRelation>()
      .withDefault(const Constant('noRelation'))();
  TextColumn get timeOfDayJson => text().withDefault(const Constant('[]'))();
  TextColumn get frequency =>
      textEnum<MedFrequency>().withDefault(const Constant('daily'))();
  TextColumn get scheduleNote => text().withDefault(const Constant(''))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get changeNote => text().withDefault(const Constant(''))();
  DateTimeColumn get changeDate => dateTime().nullable()();
  TextColumn get sourceDocumentId => text().nullable()();

  /// For medicines given every few days (EPO shots etc.): the gap in days.
  /// Null for medicines on a daily pattern.
  IntColumn get intervalDays => integer().nullable()();

  /// The day an interval medicine was last marked given. Drives the
  /// due-today checklist; null until the first dose is ticked off.
  DateTimeColumn get lastGivenOn => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One numeric lab observation, linked to the report it came from.
class LabResults extends Table {
  TextColumn get id => text()();
  TextColumn get metricCode => text()();
  RealColumn get value => real()();
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get documentId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A row on the longitudinal medical timeline.
class TimelineEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => textEnum<TimelineEventType>()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get documentId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A single scheduled dose for today's medication strip.
class Doses extends Table {
  TextColumn get id => text()();
  TextColumn get medicationId => text()();
  TextColumn get medicationLabel => text()();
  TextColumn get timeLabel => text()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get scheduledOn => dateTime()();
  BoolColumn get taken => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Persisted Ask-AI conversation.
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get citationsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Upcoming and past dialysis sessions.
class DialysisSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get center => text().withDefault(const Constant(''))();
  RealColumn get ultrafiltrationL => real().nullable()();
  RealColumn get preWeightKg => real().nullable()();
  RealColumn get postWeightKg => real().nullable()();
  RealColumn get durationHours => real().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A health-insurance policy claims are filed against. Usually one row;
/// modeled as a list because top-up policies exist.
class InsurancePolicies extends Table {
  TextColumn get id => text()();
  TextColumn get insurerName => text()();
  TextColumn get policyNumber => text()();
  TextColumn get tpaName => text().withDefault(const Constant(''))();

  /// Days from a bill's date until the insurer stops accepting it.
  IntColumn get claimWindowDays => integer().withDefault(const Constant(30))();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One reimbursement claim: a bundle of vault documents moving through
/// draft → submitted → outcome. Money is integer paise, never floats.
class Claims extends Table {
  TextColumn get id => text()();
  TextColumn get policyId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get status => textEnum<ClaimStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get submittedOn => dateTime().nullable()();
  DateTimeColumn get settledOn => dateTime().nullable()();
  IntColumn get claimedAmountPaise => integer().nullable()();
  IntColumn get approvedAmountPaise => integer().nullable()();

  /// Claim number assigned by the insurer/TPA after submission.
  TextColumn get insurerRef => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Documents attached to a claim. A document with no row here is
/// "unclaimed" — that state is always derived, never stored.
class ClaimDocuments extends Table {
  TextColumn get claimId => text()();
  TextColumn get documentId => text()();

  @override
  Set<Column<Object>> get primaryKey => {claimId, documentId};
}

/// Per-claim submission checklist. Labels are copied in at creation time
/// (localized then), so past claims keep the wording they were made with.
class ClaimChecklistItems extends Table {
  TextColumn get id => text()();
  TextColumn get claimId => text()();
  TextColumn get label => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
