import 'dart:convert';
import 'dart:io';

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
/// structured record.
class VaultExport {
  VaultExport(this._db);

  final AppDatabase _db;

  Future<Result<void>> exportAndShare() {
    return Result.guard(() async {
      final backup = await _buildBackup();
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

  Future<Map<String, dynamic>> _buildBackup() async {
    final patient = await _db.patientDao.getPatient();
    final documents = await _db.documentDao.watchAll().first;
    final activeMeds = await _db.medicationDao.watchActive().first;
    final endedMeds = await _db.medicationDao.watchEnded().first;
    final labs = await _db.labDao.getAll();
    final events =
        await _db.timelineDao.getPage(limit: 100000, offset: 0);

    return {
      'app': 'KidneyCare',
      'exportedAt': DateTime.now().toIso8601String(),
      'patient': patient == null
          ? null
          : {
              'name': patient.name,
              'age': patient.age,
              'condition': patient.conditionSummary,
              'center': patient.dialysisCenter,
              'dryWeightKg': patient.dryWeightKg,
            },
      'medications': [
        for (final med in [...activeMeds, ...endedMeds])
          {
            'name': med.name,
            'dose': med.dose,
            'frequency': med.frequencyCode,
            'purpose': med.purpose,
            'doctor': med.doctor,
            'schedule': med.scheduleNote,
            'startDate': med.startDate.toIso8601String(),
            'endDate': med.endDate?.toIso8601String(),
          },
      ],
      'labResults': [
        for (final lab in labs)
          {
            'metric': lab.metricCode,
            'value': lab.value,
            'takenAt': lab.takenAt.toIso8601String(),
          },
      ],
      'documents': [
        for (final doc in documents)
          {
            'type': doc.type.name,
            'title': doc.title,
            'hospital': doc.hospital,
            'doctor': doc.doctor,
            'date': doc.documentDate.toIso8601String(),
            'tags': jsonDecode(doc.tagsJson),
            'extractedText': doc.ocrText,
          },
      ],
      'timeline': [
        for (final event in events)
          {
            'type': event.type.name,
            'title': event.title,
            'subtitle': event.subtitle,
            'date': event.occurredAt.toIso8601String(),
          },
      ],
    };
  }
}

final vaultExportProvider = Provider<VaultExport>((ref) {
  return VaultExport(ref.watch(databaseProvider));
});
