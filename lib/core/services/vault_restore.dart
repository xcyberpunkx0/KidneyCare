import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../shared/domain/claim_status.dart';
import '../../shared/domain/document_type.dart';
import '../../shared/domain/med_schedule.dart';
import '../../shared/domain/timeline_event_type.dart';
import '../storage/app_database.dart';
import '../storage/database_provider.dart';
import '../utils/app_failure.dart';
import '../utils/result.dart';
import 'vault_export.dart';

/// What a restore put back, for the confirmation message.
class RestoreSummary {
  const RestoreSummary({
    required this.medications,
    required this.documents,
    required this.labResults,
    required this.timelineEvents,
    required this.dialysisSessions,
    required this.claims,
  });

  final int medications;
  final int documents;
  final int labResults;
  final int timelineEvents;
  final int dialysisSessions;
  final int claims;
}

/// Rebuilds the vault from a JSON backup written by [VaultExport].
///
/// Restore replaces, never merges: the file is parsed and validated in
/// full first, then every table is cleared and refilled inside one
/// transaction, so a damaged file leaves the device exactly as it was.
/// Scan images are not part of a backup; restored documents keep their
/// metadata and extracted text but show without a picture unless the
/// original files are still on this device.
class VaultRestore {
  VaultRestore(this._db);

  static const _uuid = Uuid();

  final AppDatabase _db;

  /// Opens the system file browser for a backup and restores it.
  /// Resolves to `null` when the caregiver cancels the picker.
  Future<Result<RestoreSummary?>> pickAndRestore() {
    return Result.guard(() async {
      final FilePickerResult? picked;
      try {
        picked = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: const ['json'],
          withData: true,
        );
      } catch (error, stackTrace) {
        throw PermissionFailure(
          message:
              'Files could not be opened. Check storage permission in '
              'system settings.',
          cause: error,
          stackTrace: stackTrace,
        );
      }
      final bytes = picked?.files.singleOrNull?.bytes;
      if (bytes == null) return null;
      return restoreFromJson(utf8.decode(bytes, allowMalformed: true));
    });
  }

  /// Restores from the raw text of a backup file. Throws
  /// [ValidationFailure] when the file is not a usable backup and
  /// [StorageFailure] when the database rejects it; either way nothing
  /// on the device changes.
  Future<RestoreSummary> restoreFromJson(String json) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const ValidationFailure(
        message: 'This file is not a KidneyCare backup.',
      );
    }
    if (decoded is! Map<String, dynamic> || decoded['app'] != 'KidneyCare') {
      throw const ValidationFailure(
        message: 'This file is not a KidneyCare backup.',
      );
    }
    final format = decoded['format'] ?? 1;
    if (format is! int || format < 1 || format > VaultExport.format) {
      throw const ValidationFailure(
        message:
            'This backup was made by a newer version of KidneyCare. '
            'Please update the app and try again.',
      );
    }

    final _Parsed parsed;
    try {
      parsed = format == 1 ? _parseFormat1(decoded) : _parseFormat2(decoded);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const ValidationFailure(
        message: 'This backup file is damaged and could not be read.',
      );
    }

    try {
      await _db.transaction(() async {
        await _clearVault();
        await _db.batch((batch) {
          if (parsed.patient != null) {
            batch.insert(_db.patients, parsed.patient!);
          }
          batch.insertAll(_db.documents, parsed.documents);
          batch.insertAll(_db.documentPages, parsed.pages);
          batch.insertAll(_db.medications, parsed.medications);
          batch.insertAll(_db.labResults, parsed.labs);
          batch.insertAll(_db.timelineEvents, parsed.events);
          batch.insertAll(_db.dialysisSessions, parsed.sessions);
          batch.insertAll(_db.insurancePolicies, parsed.policies);
          batch.insertAll(_db.claims, parsed.claims);
          batch.insertAll(_db.claimDocuments, parsed.claimDocuments);
          batch.insertAll(_db.claimChecklistItems, parsed.checklist);
        });
      });
    } catch (error, stackTrace) {
      throw StorageFailure(
        message:
            'The backup could not be written to this device. '
            'Your existing record is unchanged.',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    return RestoreSummary(
      medications: parsed.medications.length,
      documents: parsed.documents.length,
      labResults: parsed.labs.length,
      timelineEvents: parsed.events.length,
      dialysisSessions: parsed.sessions.length,
      claims: parsed.claims.length,
    );
  }

  Future<void> _clearVault() async {
    for (final table in <TableInfo>[
      _db.patients,
      _db.documents,
      _db.documentPages,
      _db.medications,
      _db.labResults,
      _db.timelineEvents,
      _db.doses,
      _db.chatMessages,
      _db.dialysisSessions,
      _db.insurancePolicies,
      _db.claims,
      _db.claimDocuments,
      _db.claimChecklistItems,
    ]) {
      await _db.delete(table).go();
    }
  }

  // ---------------------------------------------------------------------
  // Format 2: full record with ids (current export).
  // ---------------------------------------------------------------------

  _Parsed _parseFormat2(Map<String, dynamic> root) {
    final patientJson = root['patient'] as Map<String, dynamic>?;
    final documents = <DocumentsCompanion>[];
    final pages = <DocumentPagesCompanion>[];
    for (final doc in _list(root['documents'])) {
      documents.add(
        DocumentsCompanion.insert(
          id: doc['id'] as String,
          type: DocumentType.values.byName(doc['type'] as String),
          title: doc['title'] as String,
          hospital: _text(doc['hospital']),
          doctor: _text(doc['doctor']),
          documentDate: _date(doc['date']),
          capturedAt: _date(doc['capturedAt'] ?? doc['date']),
          originalPath: _text(doc['originalPath']),
          previewPath: _text(doc['previewPath']),
          ocrText: _text(doc['extractedText']),
          tagsJson: Value(jsonEncode(doc['tags'] ?? const [])),
          note: _text(doc['note']),
        ),
      );
      for (final page in _list(doc['pages'])) {
        pages.add(
          DocumentPagesCompanion.insert(
            id: page['id'] as String,
            documentId: doc['id'] as String,
            pageIndex: page['pageIndex'] as int,
            originalPath: page['originalPath'] as String,
          ),
        );
      }
    }

    final claims = <ClaimsCompanion>[];
    final claimDocuments = <ClaimDocumentsCompanion>[];
    final checklist = <ClaimChecklistItemsCompanion>[];
    for (final claim in _list(root['claims'])) {
      final claimId = claim['id'] as String;
      claims.add(
        ClaimsCompanion.insert(
          id: claimId,
          policyId: Value(claim['policyId'] as String?),
          title: claim['title'] as String,
          status: ClaimStatus.values.byName(claim['status'] as String),
          createdAt: _date(claim['createdAt']),
          submittedOn: _dateOrNull(claim['submittedOn']),
          settledOn: _dateOrNull(claim['settledOn']),
          claimedAmountPaise: Value(claim['claimedAmountPaise'] as int?),
          approvedAmountPaise: Value(claim['approvedAmountPaise'] as int?),
          insurerRef: _text(claim['insurerRef']),
          note: _text(claim['note']),
        ),
      );
      for (final documentId in _list<String>(claim['documentIds'])) {
        claimDocuments.add(
          ClaimDocumentsCompanion.insert(
            claimId: claimId,
            documentId: documentId,
          ),
        );
      }
      for (final item in _list(claim['checklist'])) {
        checklist.add(
          ClaimChecklistItemsCompanion.insert(
            id: item['id'] as String,
            claimId: claimId,
            label: item['label'] as String,
            isDone: Value(item['isDone'] as bool? ?? false),
            sortOrder: Value(item['sortOrder'] as int? ?? 0),
          ),
        );
      }
    }

    return _Parsed(
      patient: patientJson == null
          ? null
          : PatientsCompanion.insert(
              id: patientJson['id'] as String,
              name: patientJson['name'] as String,
              initials: patientJson['initials'] as String,
              age: patientJson['age'] as int,
              conditionSummary: _text(patientJson['condition']).value,
              dialysisCenter: _text(patientJson['center']).value,
              dryWeightKg: (patientJson['dryWeightKg'] as num).toDouble(),
              dryWeightDeltaKg: Value(
                (patientJson['dryWeightDeltaKg'] as num? ?? 0).toDouble(),
              ),
              scheduleJson: Value(jsonEncode(patientJson['schedule'] ?? {})),
              bloodGroup: _text(patientJson['bloodGroup']),
              allergies: _text(patientJson['allergies']),
              emergencyContact: _text(patientJson['emergencyContact']),
              comorbidities: _text(patientJson['comorbidities']),
            ),
      documents: documents,
      pages: pages,
      medications: [
        for (final med in _list(root['medications']))
          MedicationsCompanion.insert(
            id: med['id'] as String,
            name: med['name'] as String,
            dose: _text(med['dose']).value,
            frequencyCode: med['frequencyCode'] as String,
            purpose: _text(med['purpose']).value,
            doctor: _text(med['doctor']),
            foodRelation: Value(
              MedFoodRelation.values.byName(med['foodRelation'] as String),
            ),
            timeOfDayJson: Value(jsonEncode(med['timeOfDay'] ?? const [])),
            frequency: Value(
              MedFrequency.values.byName(med['frequency'] as String),
            ),
            scheduleNote: _text(med['scheduleNote']),
            startDate: _date(med['startDate']),
            endDate: _dateOrNull(med['endDate']),
            changeNote: _text(med['changeNote']),
            changeDate: _dateOrNull(med['changeDate']),
            sourceDocumentId: Value(med['sourceDocumentId'] as String?),
            intervalDays: Value(med['intervalDays'] as int?),
            lastGivenOn: _dateOrNull(med['lastGivenOn']),
          ),
      ],
      labs: [
        for (final lab in _list(root['labResults']))
          LabResultsCompanion.insert(
            id: lab['id'] as String,
            metricCode: lab['metric'] as String,
            value: (lab['value'] as num).toDouble(),
            takenAt: _date(lab['takenAt']),
            documentId: Value(lab['documentId'] as String?),
          ),
      ],
      events: [
        for (final event in _list(root['timeline']))
          TimelineEventsCompanion.insert(
            id: event['id'] as String,
            type: TimelineEventType.values.byName(event['type'] as String),
            title: event['title'] as String,
            subtitle: _text(event['subtitle']),
            occurredAt: _date(event['date']),
            documentId: Value(event['documentId'] as String?),
          ),
      ],
      sessions: [
        for (final session in _list(root['dialysisSessions']))
          DialysisSessionsCompanion.insert(
            id: session['id'] as String,
            scheduledAt: _date(session['scheduledAt']),
            completed: Value(session['completed'] as bool? ?? false),
            center: _text(session['center']),
            ultrafiltrationL: _real(session['ultrafiltrationL']),
            preWeightKg: _real(session['preWeightKg']),
            postWeightKg: _real(session['postWeightKg']),
            durationHours: _real(session['durationHours']),
            note: _text(session['note']),
          ),
      ],
      policies: [
        for (final policy in _list(root['policies']))
          InsurancePoliciesCompanion.insert(
            id: policy['id'] as String,
            insurerName: policy['insurerName'] as String,
            policyNumber: policy['policyNumber'] as String,
            tpaName: _text(policy['tpaName']),
            claimWindowDays: Value(policy['claimWindowDays'] as int? ?? 30),
            note: _text(policy['note']),
          ),
      ],
      claims: claims,
      claimDocuments: claimDocuments,
      checklist: checklist,
    );
  }

  // ---------------------------------------------------------------------
  // Format 1: the original export. No ids, no schedule detail, no
  // dialysis or claims. Fresh ids are minted and schema defaults fill
  // the gaps, so the caregiver gets the record back rather than nothing.
  // ---------------------------------------------------------------------

  _Parsed _parseFormat1(Map<String, dynamic> root) {
    final patientJson = root['patient'] as Map<String, dynamic>?;
    final name = patientJson?['name'] as String? ?? '';
    return _Parsed(
      patient: patientJson == null
          ? null
          : PatientsCompanion.insert(
              id: _uuid.v4(),
              name: name,
              initials: _initials(name),
              age: patientJson['age'] as int? ?? 0,
              conditionSummary: _text(patientJson['condition']).value,
              dialysisCenter: _text(patientJson['center']).value,
              dryWeightKg: (patientJson['dryWeightKg'] as num? ?? 0).toDouble(),
            ),
      documents: [
        for (final doc in _list(root['documents']))
          DocumentsCompanion.insert(
            id: _uuid.v4(),
            type: DocumentType.values.byName(doc['type'] as String),
            title: doc['title'] as String,
            hospital: _text(doc['hospital']),
            doctor: _text(doc['doctor']),
            documentDate: _date(doc['date']),
            capturedAt: _date(doc['date']),
            ocrText: _text(doc['extractedText']),
            tagsJson: Value(jsonEncode(doc['tags'] ?? const [])),
          ),
      ],
      pages: const [],
      medications: [
        for (final med in _list(root['medications']))
          MedicationsCompanion.insert(
            id: _uuid.v4(),
            name: med['name'] as String,
            dose: _text(med['dose']).value,
            frequencyCode: _text(med['frequency']).value,
            purpose: _text(med['purpose']).value,
            doctor: _text(med['doctor']),
            scheduleNote: _text(med['schedule']),
            startDate: _date(med['startDate']),
            endDate: _dateOrNull(med['endDate']),
          ),
      ],
      labs: [
        for (final lab in _list(root['labResults']))
          LabResultsCompanion.insert(
            id: _uuid.v4(),
            metricCode: lab['metric'] as String,
            value: (lab['value'] as num).toDouble(),
            takenAt: _date(lab['takenAt']),
          ),
      ],
      events: [
        for (final event in _list(root['timeline']))
          TimelineEventsCompanion.insert(
            id: _uuid.v4(),
            type: TimelineEventType.values.byName(event['type'] as String),
            title: event['title'] as String,
            subtitle: _text(event['subtitle']),
            occurredAt: _date(event['date']),
          ),
      ],
      sessions: const [],
      policies: const [],
      claims: const [],
      claimDocuments: const [],
      checklist: const [],
    );
  }

  /// Mirrors PatientProfile.initials, which lives in the patient feature
  /// and is not reachable from core.
  static String _initials(String name) {
    final letters = name
        .trim()
        .split(RegExp(r'\s+'))
        .map((part) => part.replaceAll(RegExp(r'[^A-Za-z]'), ''))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();
    return letters.isEmpty ? '·' : letters;
  }

  static List<T> _list<T>(Object? value) =>
      value == null ? const [] : (value as List).cast<T>();

  static Value<String> _text(Object? value) => Value(value as String? ?? '');

  static Value<double?> _real(Object? value) =>
      Value((value as num?)?.toDouble());

  static DateTime _date(Object? value) => DateTime.parse(value as String);

  static Value<DateTime?> _dateOrNull(Object? value) =>
      Value(value == null ? null : DateTime.parse(value as String));
}

/// Everything a backup contained, parsed into companions and ready to
/// write. Built in full before any table is touched.
class _Parsed {
  const _Parsed({
    required this.patient,
    required this.documents,
    required this.pages,
    required this.medications,
    required this.labs,
    required this.events,
    required this.sessions,
    required this.policies,
    required this.claims,
    required this.claimDocuments,
    required this.checklist,
  });

  final PatientsCompanion? patient;
  final List<DocumentsCompanion> documents;
  final List<DocumentPagesCompanion> pages;
  final List<MedicationsCompanion> medications;
  final List<LabResultsCompanion> labs;
  final List<TimelineEventsCompanion> events;
  final List<DialysisSessionsCompanion> sessions;
  final List<InsurancePoliciesCompanion> policies;
  final List<ClaimsCompanion> claims;
  final List<ClaimDocumentsCompanion> claimDocuments;
  final List<ClaimChecklistItemsCompanion> checklist;
}

final vaultRestoreProvider = Provider<VaultRestore>((ref) {
  return VaultRestore(ref.watch(databaseProvider));
});
