import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/record_tile.dart';
import '../../../../shared/domain/document_type.dart';
import '../../../../shared/domain/timeline_event_type.dart';
import '../../../medications/presentation/widgets/medication_card.dart';
import '../controllers/search_controller.dart';

/// Global instant search across documents, medicines and the timeline.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: ref.read(globalSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final query = ref.watch(globalSearchQueryProvider);
    final results = ref.watch(globalSearchResultsProvider);

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
        title: Text(
          l10n.search,
          style: typo.sectionTitle.copyWith(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: AppSearchBar(
                hint: l10n.globalSearchHint,
                controller: _controller,
                autofocus: true,
                onChanged: (value) => ref
                    .read(globalSearchQueryProvider.notifier)
                    .setQuery(value),
              ),
            ),
            Expanded(child: _resultsView(query, results)),
          ],
        ),
      ),
    );
  }

  Widget _resultsView(
    String query,
    AsyncValue<GlobalSearchResults> results,
  ) {
    final l10n = context.l10n;
    if (query.trim().length < 2) {
      return EmptyState(
        icon: Icons.search,
        title: l10n.searchVaultTitle,
        message: l10n.searchVaultMessage,
      );
    }
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => EmptyState(
        icon: Icons.search_off,
        title: l10n.searchUnavailableTitle,
        message: l10n.searchUnavailableMessage,
      ),
      data: (data) {
        if (data.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: l10n.nothingFoundTitle,
            message: l10n.nothingFoundMessage,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          children: [
            if (data.documents.isNotEmpty) ...[
              _SectionLabel(label: l10n.sectionDocuments),
              for (final doc in data.documents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: RecordTile(
                    type: _docEventType(doc),
                    title: doc.title,
                    subtitle: [
                      if (doc.hospital.isNotEmpty) doc.hospital,
                      if (doc.doctor.isNotEmpty) doc.doctor,
                    ].join(' · '),
                    dateLabel: doc.documentDate.monthDay,
                    onTap: () => context.pushNamed(
                      'documentViewer',
                      pathParameters: {'id': doc.id},
                    ),
                  ),
                ),
            ],
            if (data.medications.isNotEmpty) ...[
              _SectionLabel(label: l10n.sectionMedicines),
              for (final med in data.medications)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.medications),
                    child: MedicationCard(medication: med),
                  ),
                ),
            ],
            if (data.events.isNotEmpty) ...[
              _SectionLabel(label: l10n.sectionTimeline),
              for (final event in data.events)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: RecordTile(
                    type: event.type,
                    title: event.title,
                    subtitle: event.subtitle,
                    dateLabel: event.occurredAt.monthDay,
                    onTap: event.documentId == null
                        ? null
                        : () => context.pushNamed(
                              'documentViewer',
                              pathParameters: {'id': event.documentId!},
                            ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  TimelineEventType _docEventType(Document doc) {
    return switch (doc.type) {
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
      child: Text(
        label,
        style: context.typo.overline.copyWith(
          fontSize: 11,
          color: context.colors.muted,
        ),
      ),
    );
  }
}
