import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../domain/repositories/documents_repository.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Document>> watchAll() => _db.documentDao.watchAll();

  @override
  Future<Document?> getById(String id) => _db.documentDao.getById(id);

  @override
  Future<List<DocumentPage>> pagesFor(String documentId) =>
      _db.documentDao.pagesFor(documentId);
}

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  return DocumentsRepositoryImpl(ref.watch(databaseProvider));
});

final allDocumentsProvider = StreamProvider<List<Document>>((ref) {
  return ref.watch(documentsRepositoryProvider).watchAll();
});
