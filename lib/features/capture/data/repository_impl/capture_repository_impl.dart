import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/image_store.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/document_type.dart';
import '../../../../shared/domain/med_schedule.dart';
import '../../../../shared/domain/timeline_event_type.dart';
import '../../domain/entities/extraction.dart';
import '../../domain/repositories/capture_repository.dart';
import '../datasources/gemini_extraction_datasource.dart';

class CaptureRepositoryImpl implements CaptureRepository {
  CaptureRepositoryImpl(this._datasource, this._db, this._imageStore);

  final GeminiExtractionDatasource _datasource;
  final AppDatabase _db;
  final ImageStore _imageStore;

  static const _uuid = Uuid();

  @override
  Future<Result<ExtractionResult>> extract(Uint8List jpegBytes) {
    return Result.guard(() async {
      final dto = await _datasource.extract(jpegBytes);
      return dto.toDomain();
    });
  }

  @override
  Future<Result<String>> saveReviewed({
    required Uint8List originalBytes,
    required ExtractionResult reviewed,
  }) {
    return Result.guard(() async {
      final documentId = _uuid.v4();
      final scan = await _imageStore.persist(originalBytes, documentId);
      final now = DateTime.now();

      await _db.transaction(() async {
        await _db.documentDao.upsert(DocumentsCompanion(
          id: Value(documentId),
          type: Value(reviewed.documentType),
          title: Value(reviewed.title),
          hospital: Value(reviewed.hospital),
          doctor: Value(reviewed.doctor),
          documentDate: Value(reviewed.documentDate),
          capturedAt: Value(now),
          originalPath: Value(scan.originalPath),
          previewPath: Value(scan.previewPath),
          ocrText: Value(reviewed.ocrText),
          tagsJson: Value(jsonEncode(reviewed.tags)),
        ));

        await _db.labDao.insertAll([
          for (final lab in reviewed.labValues)
            LabResultsCompanion(
              id: Value(_uuid.v4()),
              metricCode: Value(lab.metricCode),
              value: Value(lab.value),
              takenAt: Value(reviewed.documentDate),
              documentId: Value(documentId),
            ),
        ]);

        for (final medicine in reviewed.medicines) {
          if (medicine.name.isEmpty) continue;
          await _db.medicationDao.upsert(MedicationsCompanion(
            id: Value('med-${medicine.name.toLowerCase().replaceAll(' ', '-')}'),
            name: Value(medicine.name),
            dose: Value(medicine.dose),
            frequencyCode: Value(
                medicine.frequency.isEmpty ? '—' : medicine.frequency),
            purpose: const Value(''),
            doctor: Value(reviewed.doctor),
            scheduleGroup: Value(_scheduleGroupFor(medicine)),
            timingCuesJson: Value(jsonEncode(_cuesFor(medicine))),
            scheduleNote: Value(medicine.instruction),
            startDate: Value(reviewed.documentDate),
            sourceDocumentId: Value(documentId),
          ));
        }

        await _db.timelineDao.insert(TimelineEventsCompanion(
          id: Value(_uuid.v4()),
          type: Value(_timelineTypeFor(reviewed.documentType)),
          title: Value(reviewed.title),
          subtitle: Value([
            if (reviewed.hospital.isNotEmpty) reviewed.hospital,
            if (reviewed.doctor.isNotEmpty) reviewed.doctor,
          ].join(' · ')),
          occurredAt: Value(reviewed.documentDate),
          documentId: Value(documentId),
        ));
      });
      return documentId;
    });
  }

  MedScheduleGroup _scheduleGroupFor(ExtractedMedicine medicine) {
    final instruction = medicine.instruction.toLowerCase();
    if (instruction.contains('week')) return MedScheduleGroup.weekly;
    if (instruction.contains('food') || instruction.contains('meal')) {
      return MedScheduleGroup.withFood;
    }
    return MedScheduleGroup.byClock;
  }

  List<String> _cuesFor(ExtractedMedicine medicine) {
    final instruction = medicine.instruction.toLowerCase();
    return [
      if (instruction.contains('before food') ||
          instruction.contains('empty stomach'))
        MedTimingCue.beforeFood.name
      else if (instruction.contains('after food') ||
          instruction.contains('after meal'))
        MedTimingCue.afterFood.name
      else if (instruction.contains('food') || instruction.contains('meal'))
        MedTimingCue.withFood.name,
      if (instruction.contains('morning')) MedTimingCue.morning.name,
      if (instruction.contains('noon')) MedTimingCue.noon.name,
      if (instruction.contains('night') || instruction.contains('bedtime'))
        MedTimingCue.night.name,
      if (instruction.contains('dialysis'))
        MedTimingCue.dialysisDayOnly.name,
    ];
  }

  TimelineEventType _timelineTypeFor(DocumentType type) {
    return switch (type) {
      DocumentType.labReport => TimelineEventType.labReport,
      DocumentType.prescription => TimelineEventType.prescription,
      DocumentType.dischargeSummary => TimelineEventType.discharge,
      DocumentType.bill => TimelineEventType.bill,
      DocumentType.handwrittenNote ||
      DocumentType.scan =>
        TimelineEventType.doctorVisit,
    };
  }
}

final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  return CaptureRepositoryImpl(
    ref.watch(geminiExtractionDatasourceProvider),
    ref.watch(databaseProvider),
    ref.watch(imageStoreProvider),
  );
});
