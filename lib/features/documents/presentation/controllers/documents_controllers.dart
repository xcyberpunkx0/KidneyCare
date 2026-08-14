import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../shared/domain/document_type.dart';
import '../../data/repository_impl/documents_repository_impl.dart';

/// Active type filter; null means "All".
class DocumentFilterController extends Notifier<DocumentType?> {
  @override
  DocumentType? build() => null;

  void select(DocumentType? type) => state = type;

  void selectByName(String? name) {
    if (name == null) {
      state = null;
      return;
    }
    state = DocumentType.values.asNameMap()[name];
  }
}

final documentFilterProvider =
    NotifierProvider<DocumentFilterController, DocumentType?>(
  DocumentFilterController.new,
);

/// Live search text within the library.
class DocumentSearchController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final documentSearchProvider =
    NotifierProvider<DocumentSearchController, String>(
  DocumentSearchController.new,
);

/// Documents after applying the type filter and search text. Filtering is
/// in-memory over the watched list, so results update as the user types.
final filteredDocumentsProvider = Provider<AsyncValue<List<Document>>>((ref) {
  final documents = ref.watch(allDocumentsProvider);
  final filter = ref.watch(documentFilterProvider);
  final query = ref.watch(documentSearchProvider).trim().toLowerCase();

  return documents.whenData((docs) {
    return [
      for (final doc in docs)
        if (filter == null || doc.type == filter)
          if (query.isEmpty || _matches(doc, query)) doc,
    ];
  });
});

bool _matches(Document doc, String query) {
  return doc.title.toLowerCase().contains(query) ||
      doc.hospital.toLowerCase().contains(query) ||
      doc.doctor.toLowerCase().contains(query) ||
      doc.tagsJson.toLowerCase().contains(query) ||
      doc.ocrText.toLowerCase().contains(query);
}
