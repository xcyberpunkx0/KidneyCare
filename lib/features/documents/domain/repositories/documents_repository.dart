import '../../../../core/storage/app_database.dart';

/// Read/write access to the document library metadata.
abstract interface class DocumentsRepository {
  Stream<List<Document>> watchAll();

  Future<Document?> getById(String id);

  /// Page rows for a multi-page document, ordered by page index.
  /// Empty for classic single-image documents.
  Future<List<DocumentPage>> pagesFor(String documentId);
}
