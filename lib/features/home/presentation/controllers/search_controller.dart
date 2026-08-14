import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';

/// Grouped results of a global vault search.
class GlobalSearchResults {
  const GlobalSearchResults({
    this.documents = const [],
    this.medications = const [],
    this.events = const [],
  });

  final List<Document> documents;
  final List<Medication> medications;
  final List<TimelineEvent> events;

  bool get isEmpty =>
      documents.isEmpty && medications.isEmpty && events.isEmpty;
}

class GlobalSearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final globalSearchQueryProvider =
    NotifierProvider<GlobalSearchQueryController, String>(
  GlobalSearchQueryController.new,
);

/// Runs the three sub-searches in parallel on every keystroke. SQLite over
/// local data keeps this instant.
final globalSearchResultsProvider =
    FutureProvider<GlobalSearchResults>((ref) async {
  final query = ref.watch(globalSearchQueryProvider).trim();
  if (query.length < 2) return const GlobalSearchResults();

  final db = ref.watch(databaseProvider);
  final (documents, medications, events) = await (
    db.documentDao.search(query),
    db.medicationDao.search(query),
    db.timelineDao.search(query),
  ).wait;

  return GlobalSearchResults(
    documents: documents,
    medications: medications,
    events: events,
  );
});
