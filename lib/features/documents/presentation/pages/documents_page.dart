import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/capture_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../shared/domain/document_type.dart';
import '../controllers/documents_controllers.dart';
import '../widgets/document_card.dart';

/// Documents library — filter chips, instant search, two-column grid.
class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key, this.initialFilter});

  /// Optional [DocumentType] name from the route query, e.g. "labReport".
  final String? initialFilter;

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: ref.read(documentSearchProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(documentFilterProvider.notifier)
            .selectByName(widget.initialFilter);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final filter = ref.watch(documentFilterProvider);
    final documents = ref.watch(filteredDocumentsProvider);
    final total = documents.value?.length ?? 0;

    return Scaffold(
      backgroundColor: colors.bgSection,
      floatingActionButton: const CaptureButton(),
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      l10n.documents,
                      style: typo.pageTitle.copyWith(fontSize: 25),
                    ),
                  ),
                  Text(
                    l10n.nScans(total),
                    style: typo.bodySmall.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
              child: AppSearchBar(
                hint: l10n.documentsSearchHint,
                controller: _searchController,
                onChanged: (query) => ref
                    .read(documentSearchProvider.notifier)
                    .setQuery(query),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                children: [
                  AppChoiceChip(
                    label: l10n.filterAll,
                    selected: filter == null,
                    onTap: () => ref
                        .read(documentFilterProvider.notifier)
                        .select(null),
                  ),
                  for (final type in DocumentType.values) ...[
                    const SizedBox(width: 8),
                    AppChoiceChip(
                      label: type.localizedLabel(l10n),
                      selected: filter == type,
                      onTap: () => ref
                          .read(documentFilterProvider.notifier)
                          .select(type),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: documents.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, _) => EmptyState(
                  icon: Icons.folder_outlined,
                  title: l10n.documentsUnavailableTitle,
                  message: l10n.documentsUnavailableMessage,
                ),
                data: (docs) {
                  if (docs.isEmpty) {
                    return EmptyState(
                      icon: Icons.folder_outlined,
                      title: l10n.noDocumentsTitle,
                      message: l10n.noDocumentsMessage,
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, AppShell.navClearance),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 200,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) => DocumentCard(
                      document: docs[index],
                      onTap: () => context.pushNamed(
                        'documentViewer',
                        pathParameters: {'id': docs[index].id},
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
