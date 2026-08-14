import 'package:drift/drift.dart';

import '../../../shared/domain/document_type.dart';
import '../app_database.dart';
import '../tables.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [Documents])
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

  Future<void> deleteById(String id) {
    return (delete(documents)..where((t) => t.id.equals(id))).go();
  }
}
