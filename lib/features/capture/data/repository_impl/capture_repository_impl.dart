import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/image_store.dart';
import '../../../../core/services/scan_page.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/document_type.dart';
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
  Future<Result<ExtractionResult>> extract(List<ScanPage> pages) {
    return Result.guard(() async {
      final dto = await _datasource.extract(pages);
      return dto.toDomain();
    });
  }

  @override
  Future<Result<String>> saveReviewed({
    required List<ScanPage> pages,
    required ExtractionResult reviewed,
  }) {
    return Result.guard(() async {
      // Only lab reports go through extraction now, so the saved type is
      // pinned here rather than trusted from the model's classification.
      final documentId = await _persistDocument(
        pages: pages,
        type: DocumentType.labReport,
        title: reviewed.title,
        hospital: reviewed.hospital,
        doctor: reviewed.doctor,
        documentDate: reviewed.documentDate,
        ocrText: reviewed.ocrText,
        tags: reviewed.tags,
        writeExtras: (documentId) async {
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
        },
      );
      return documentId;
    });
  }

  @override
  Future<Result<String>> saveManual({
    required List<ScanPage> pages,
    required DocumentType type,
    required String title,
    String doctor = '',
    required DateTime documentDate,
  }) {
    return Result.guard(() {
      return _persistDocument(
        pages: pages,
        type: type,
        title: title,
        hospital: '',
        doctor: doctor,
        documentDate: documentDate,
        ocrText: '',
        tags: const [],
      );
    });
  }

  /// Stores the page images and writes the document plus its timeline
  /// entry in one transaction; [writeExtras] runs inside it for rows
  /// that must live or die with the document.
  Future<String> _persistDocument({
    required List<ScanPage> pages,
    required DocumentType type,
    required String title,
    required String hospital,
    required String doctor,
    required DateTime documentDate,
    required String ocrText,
    required List<String> tags,
    Future<void> Function(String documentId)? writeExtras,
  }) async {
    final documentId = _uuid.v4();

    // Single-page documents keep the original storage layout; multi-page
    // ones store every page and additionally get DocumentPages rows.
    final String originalPath;
    final String previewPath;
    List<String> pagePaths = const [];
    if (pages.length == 1) {
      final scan = await _imageStore.persist(pages.single.bytes, documentId);
      originalPath = scan.originalPath;
      previewPath = scan.previewPath;
    } else {
      final stored = await _imageStore.persistPages(pages, documentId);
      pagePaths = stored.pagePaths;
      originalPath = stored.pagePaths.first;
      previewPath = stored.previewPath;
    }
    final now = DateTime.now();

    await _db.transaction(() async {
      if (pagePaths.length > 1) {
        await _db.documentDao.insertPages([
          for (var i = 0; i < pagePaths.length; i++)
            DocumentPagesCompanion(
              id: Value(_uuid.v4()),
              documentId: Value(documentId),
              pageIndex: Value(i),
              originalPath: Value(pagePaths[i]),
            ),
        ]);
      }
      await _db.documentDao.upsert(DocumentsCompanion(
        id: Value(documentId),
        type: Value(type),
        title: Value(title),
        hospital: Value(hospital),
        doctor: Value(doctor),
        documentDate: Value(documentDate),
        capturedAt: Value(now),
        originalPath: Value(originalPath),
        previewPath: Value(previewPath),
        ocrText: Value(ocrText),
        tagsJson: Value(jsonEncode(tags)),
      ));

      await writeExtras?.call(documentId);

      await _db.timelineDao.insert(TimelineEventsCompanion(
        id: Value(_uuid.v4()),
        type: Value(_timelineTypeFor(type)),
        title: Value(title),
        subtitle: Value([
          if (hospital.isNotEmpty) hospital,
          if (doctor.isNotEmpty) doctor,
        ].join(' · ')),
        occurredAt: Value(documentDate),
        documentId: Value(documentId),
      ));
    });
    return documentId;
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
