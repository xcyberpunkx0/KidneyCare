import 'package:drift/drift.dart';

import '../../../shared/domain/document_type.dart';
import '../app_database.dart';
import '../tables.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [Documents, DocumentPages])
class DocumentDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentDaoMixin {
  DocumentDao(super.db);

  Stream<List<Document>> watchAll() {
    final query = select(documents)
      ..orderBy([(t) => OrderingTerm.desc(t.documentDate)]);
    return query.watch();
  }

  Stream<List<Document>> watchRecent(int limit) {
    final query = select(documents)
      ..orderBy([(t) => OrderingTerm.desc(t.documentDate)])
      ..limit(limit);
    return query.watch();
  }

  Stream<Map<DocumentType, int>> watchCountsByType() {
    final count = documents.id.count();
    final query = selectOnly(documents)
      ..addColumns([documents.type, count])
      ..groupBy([documents.type]);
    return query.watch().map((rows) {
      return {
        for (final row in rows)
          DocumentType.values.byName(row.read(documents.type)!):
              row.read(count) ?? 0,
      };
    });
  }

  Future<Document?> getById(String id) {
    return (select(documents)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Case-insensitive search across title, hospital, doctor, tags and OCR
  /// text. Backing a debounce-free instant search box, so it must stay fast:
  /// single indexed-table scan with LIKE.
  Future<List<Document>> search(String term) {
    final pattern = '%${term.toLowerCase()}%';
    final query = select(documents)
      ..where((t) =>
          t.title.lower().like(pattern) |
          t.hospital.lower().like(pattern) |
          t.doctor.lower().like(pattern) |
          t.tagsJson.lower().like(pattern) |
          t.ocrText.lower().like(pattern))
      ..orderBy([(t) => OrderingTerm.desc(t.documentDate)]);
    return query.get();
  }

  Future<void> upsert(DocumentsCompanion entry) {
    return into(documents).insertOnConflictUpdate(entry);
  }

  /// Page images of a multi-page document, in reading order. Empty for
  /// documents captured as a single image — callers fall back to
  /// Documents.originalPath.
  Future<List<DocumentPage>> pagesFor(String documentId) {
    final query = select(documentPages)
      ..where((t) => t.documentId.equals(documentId))
      ..orderBy([(t) => OrderingTerm.asc(t.pageIndex)]);
    return query.get();
  }

  Future<void> insertPages(List<DocumentPagesCompanion> pages) {
    return batch((b) => b.insertAll(documentPages, pages));
  }

  Future<void> deleteById(String id) async {
    await (delete(documentPages)..where((t) => t.documentId.equals(id))).go();
    await (delete(documents)..where((t) => t.id.equals(id))).go();
  }
}
