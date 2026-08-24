import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../storage/app_database.dart';
import '../storage/database_provider.dart';
import '../utils/app_failure.dart';
import '../utils/result.dart';

/// Exports the entire vault as a JSON backup and hands it to the system
/// share sheet, so the caregiver can keep a copy anywhere they trust.
/// Original scan images stay on the device; the backup carries the
/// structured record with its ids, so [VaultRestore] can rebuild the
/// vault exactly on a fresh install.
class VaultExport {
  VaultExport(this._db);

  /// Bumped whenever the backup shape changes. Format 1 (no `format`
  /// key) was the original lossy export; restore still reads it.
  static const format = 2;

  final AppDatabase _db;

  Future<Result<void>> exportAndShare() {
    return Result.guard(() async {
      final backup = await buildBackup();
      final directory = await getTemporaryDirectory();
      final stamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File(p.join(directory.path, 'kidneycare-backup-$stamp.json'));
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backup),
        flush: true,
      );

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'KidneyCare vault backup $stamp',
      );
      if (result.status == ShareResultStatus.unavailable) {
        throw const StorageFailure(
          message: 'Sharing is not available on this device.',
        );
      }
    });
  }

  /// The full backup document. Every table that holds the caregiver's
  /// record is included with its ids; today's dose strip and the Ask-AI
  /// chat are derived or disposable and are left out.
  Future<Map<String, dynamic>> buildBackup() async {
    final patient = await _db.patientDao.getPatient();
    final documents = await _all(_db.documents);
    final pages = await _all(_db.documentPages);
    final medications = await _all(_db.medications);
    final labs = await _all(_db.labResults);
    final events = await _all(_db.timelineEvents);
    final sessions = await _all(_db.dialysisSessions);
    final policies = await _all(_db.insurancePolicies);
    final claims = await _all(_db.claims);
    final claimDocs = await _all(_db.claimDocuments);
    final checklist = await _all(_db.claimChecklistItems);

    final pagesByDocument = <String, List<DocumentPage>>{};
    for (final page in pages) {
      pagesByDocument.putIfAbsent(page.documentId, () => []).add(page);
    }
    for (final list in pagesByDocument.values) {
      list.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
    }

    return {
      'app': 'KidneyCare',
      'format': format,
      'exportedAt': DateTime.now().toIso8601String(),
      'patient': patient == null
          ? null
          : {
              'id': patient.id,
              'name': patient.name,
              'initials': patient.initials,
              'age': patient.age,
              'condition': patient.conditionSummary,
              'center': patient.dialysisCenter,
              'dryWeightKg': patient.dryWeightKg,
              'dryWeightDeltaKg': patient.dryWeightDeltaKg,
              'schedule': jsonDecode(patient.scheduleJson),
              'bloodGroup': patient.bloodGroup,
              'allergies': patient.allergies,
              'emergencyContact': patient.emergencyContact,
              'comorbidities': patient.comorbidities,
            },
      'medications': [
        for (final med in medications)
          {
            'id': med.id,
            'name': med.name,
            'dose': med.dose,
            'frequencyCode': med.frequencyCode,
            'purpose': med.purpose,
            'doctor': med.doctor,
            'foodRelation': med.foodRelation.name,
            'timeOfDay': jsonDecode(med.timeOfDayJson),
            'frequency': med.frequency.name,
            'scheduleNote': med.scheduleNote,
            'startDate': med.startDate.toIso8601String(),
            'endDate': med.endDate?.toIso8601String(),
            'changeNote': med.changeNote,
            'changeDate': med.changeDate?.toIso8601String(),
            'sourceDocumentId': med.sourceDocumentId,
            'intervalDays': med.intervalDays,
            'lastGivenOn': med.lastGivenOn?.toIso8601String(),
          },
      ],
      'labResults': [
        for (final lab in labs)
          {
            'id': lab.id,
            'metric': lab.metricCode,
            'value': lab.value,
            'takenAt': lab.takenAt.toIso8601String(),
            'documentId': lab.documentId,
          },
      ],
      'documents': [
        for (final doc in documents)
          {
            'id': doc.id,
            'type': doc.type.name,
            'title': doc.title,
            'hospital': doc.hospital,
            'doctor': doc.doctor,
            'date': doc.documentDate.toIso8601String(),
            'capturedAt': doc.capturedAt.toIso8601String(),
            'originalPath': doc.originalPath,
            'previewPath': doc.previewPath,
            'tags': jsonDecode(doc.tagsJson),
            'extractedText': doc.ocrText,
            'note': doc.note,
            'pages': [
              for (final page in pagesByDocument[doc.id] ?? const [])
                {
                  'id': page.id,
                  'pageIndex': page.pageIndex,
                  'originalPath': page.originalPath,
                },
            ],
          },
      ],
      'timeline': [
        for (final event in events)
          {
            'id': event.id,
            'type': event.type.name,
            'title': event.title,
            'subtitle': event.subtitle,
            'date': event.occurredAt.toIso8601String(),
            'documentId': event.documentId,
          },
      ],
      'dialysisSessions': [
        for (final session in sessions)
          {
            'id': session.id,
            'scheduledAt': session.scheduledAt.toIso8601String(),
            'completed': session.completed,
            'center': session.center,
            'ultrafiltrationL': session.ultrafiltrationL,
            'preWeightKg': session.preWeightKg,
            'postWeightKg': session.postWeightKg,
            'durationHours': session.durationHours,
            'note': session.note,
          },
      ],
      'policies': [
        for (final policy in policies)
          {
            'id': policy.id,
            'insurerName': policy.insurerName,
            'policyNumber': policy.policyNumber,
            'tpaName': policy.tpaName,
            'claimWindowDays': policy.claimWindowDays,
            'note': policy.note,
          },
      ],
      'claims': [
        for (final claim in claims)
          {
            'id': claim.id,
            'policyId': claim.policyId,
            'title': claim.title,
            'status': claim.status.name,
            'createdAt': claim.createdAt.toIso8601String(),
            'submittedOn': claim.submittedOn?.toIso8601String(),
            'settledOn': claim.settledOn?.toIso8601String(),
            'claimedAmountPaise': claim.claimedAmountPaise,
            'approvedAmountPaise': claim.approvedAmountPaise,
            'insurerRef': claim.insurerRef,
            'note': claim.note,
            'documentIds': [
              for (final link in claimDocs)
                if (link.claimId == claim.id) link.documentId,
            ],
            'checklist': [
              for (final item in checklist)
                if (item.claimId == claim.id)
                  {
                    'id': item.id,
                    'label': item.label,
                    'isDone': item.isDone,
                    'sortOrder': item.sortOrder,
                  },
            ],
          },
      ],
    };
  }

  Future<List<D>> _all<T extends Table, D>(TableInfo<T, D> table) {
    return (_db.select(table)..orderBy([
          for (final column in table.$primaryKey)
            (_) => OrderingTerm.asc(column),
        ]))
        .get();
  }
}

final vaultExportProvider = Provider<VaultExport>((ref) {
  return VaultExport(ref.watch(databaseProvider));
});
