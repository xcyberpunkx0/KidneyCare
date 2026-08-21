import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/services/gemini_client.dart';
import 'package:recora/core/services/image_store.dart';
import 'package:recora/core/services/scan_page.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/features/capture/data/datasources/gemini_extraction_datasource.dart';
import 'package:recora/features/capture/data/repository_impl/capture_repository_impl.dart';
import 'package:recora/features/capture/domain/entities/extraction.dart';
import 'package:recora/shared/domain/document_type.dart';

/// Records paths without touching the filesystem or the image codec.
class _FakeImageStore extends ImageStore {
  @override
  Future<StoredScan> persist(Uint8List originalBytes, String id) async {
    return StoredScan(
      originalPath: 'scans/$id.jpg',
      previewPath: 'previews/$id.png',
    );
  }

  @override
  Future<StoredPages> persistPages(List<ScanPage> pages, String id) async {
    return StoredPages(
      pagePaths: [
        for (var i = 0; i < pages.length; i++)
          'scans/${id}_p$i.${pages[i].extension}',
      ],
      previewPath: 'previews/$id.png',
    );
  }
}

ExtractionResult _extraction() {
  return ExtractionResult(
    documentType: DocumentType.labReport,
    title: 'Monthly panel',
    hospital: 'Kaveri',
    doctor: 'Dr. Menon',
    documentDate: DateTime(2026, 8, 10),
    fields: const [
      ExtractedField(
        key: 'hb',
        label: 'HB',
        value: '9.4',
        confidence: 0.97,
      ),
    ],
    labValues: const [ExtractedLabValue(metricCode: 'hb', value: 9.4)],
  );
}

void main() {
  late AppDatabase db;
  late CaptureRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // saveReviewed never calls the datasource; a client with no key is
    // an inert stand-in.
    repository = CaptureRepositoryImpl(
      GeminiExtractionDatasource(GeminiClient(Dio(), '')),
      db,
      _FakeImageStore(),
    );
  });
  tearDown(() => db.close());

  ScanPage page(int seed) => ScanPage.png(Uint8List.fromList([seed]));

  Future<String> save(List<ScanPage> pages) async {
    final result = await repository.saveReviewed(
      pages: pages,
      reviewed: _extraction(),
    );
    return result.when(
      ok: (id) => id,
      err: (failure) => fail('save failed: ${failure.message}'),
    );
  }

  test('multi-page save writes one document plus ordered page rows',
      () async {
    final id = await save([page(1), page(2), page(3)]);

    final document = await db.documentDao.getById(id);
    expect(document, isNotNull);
    expect(document!.originalPath, 'scans/${id}_p0.png');
    expect(document.previewPath, 'previews/$id.png');

    final pages = await db.documentDao.pagesFor(id);
    expect(pages, hasLength(3));
    expect([for (final p in pages) p.pageIndex], [0, 1, 2]);
    expect(
      [for (final p in pages) p.originalPath],
      ['scans/${id}_p0.png', 'scans/${id}_p1.png', 'scans/${id}_p2.png'],
    );

    final labs = await db.labDao.getAll();
    expect(labs, hasLength(1));
    // Extraction no longer feeds the medicine list.
    expect(await db.select(db.medications).get(), isEmpty);
  });

  test('single-page save keeps the classic layout with no page rows',
      () async {
    final id = await save([page(1)]);

    final document = await db.documentDao.getById(id);
    expect(document!.originalPath, 'scans/$id.jpg');
    expect(await db.documentDao.pagesFor(id), isEmpty);
  });

  test('deleting a document removes its page rows too', () async {
    final id = await save([page(1), page(2)]);
    expect(await db.documentDao.pagesFor(id), hasLength(2));

    await db.documentDao.deleteById(id);

    expect(await db.documentDao.getById(id), isNull);
    expect(await db.documentDao.pagesFor(id), isEmpty);
  });

  test('saveManual stores the typed details and touches nothing else',
      () async {
    final result = await repository.saveManual(
      pages: [page(1)],
      type: DocumentType.prescription,
      title: "Dr Mehta's prescription",
      doctor: 'Dr Mehta',
      documentDate: DateTime(2026, 8, 12),
    );
    final id = result.when(
      ok: (id) => id,
      err: (failure) => fail('save failed: ${failure.message}'),
    );

    final document = await db.documentDao.getById(id);
    expect(document, isNotNull);
    expect(document!.type, DocumentType.prescription);
    expect(document.title, "Dr Mehta's prescription");
    expect(document.doctor, 'Dr Mehta');
    expect(document.documentDate, DateTime(2026, 8, 12));
    expect(document.ocrText, isEmpty);
    expect(document.originalPath, 'scans/$id.jpg');

    // No AI artifacts: no lab values, no medicines.
    expect(await db.labDao.getAll(), isEmpty);
    expect(await db.select(db.medications).get(), isEmpty);

    final events = await db.select(db.timelineEvents).get();
    expect(events, hasLength(1));
    expect(events.single.documentId, id);
  });

  test('saveManual with several pages writes ordered page rows',
      () async {
    final result = await repository.saveManual(
      pages: [page(1), page(2)],
      type: DocumentType.bill,
      title: 'Pharmacy bill',
      documentDate: DateTime(2026, 8, 1),
    );
    final id = result.when(
      ok: (id) => id,
      err: (failure) => fail('save failed: ${failure.message}'),
    );

    final pages = await db.documentDao.pagesFor(id);
    expect(pages, hasLength(2));
    expect([for (final p in pages) p.pageIndex], [0, 1]);
  });
}
