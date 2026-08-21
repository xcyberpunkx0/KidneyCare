import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/services/document_share.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/repository_impl/documents_repository_impl.dart';
import '../widgets/document_paper_preview.dart';

final _documentByIdProvider =
    FutureProvider.family<Document?, String>((ref, id) {
  return ref.watch(documentsRepositoryProvider).getById(id);
});

final _documentPagesProvider =
    FutureProvider.family<List<DocumentPage>, String>((ref, id) {
  return ref.watch(documentsRepositoryProvider).pagesFor(id);
});

/// Full-screen document view: original scan (or placeholder), metadata and
/// extracted text.
class DocumentViewerPage extends ConsumerWidget {
  const DocumentViewerPage({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final document = ref.watch(_documentByIdProvider(documentId));

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
        actions: [
          if (document.value != null)
            IconButton(
              icon: Icon(Icons.share_outlined, color: colors.ink),
              tooltip: l10n.shareDocument,
              onPressed: () async {
                final result =
                    await ref.read(documentShareProvider).share(documentId);
                final failure = result.failureOrNull;
                if (failure != null && context.mounted) {
                  showAppSnackBar(context, failure.message);
                }
              },
            ),
        ],
      ),
      body: document.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _MissingDocument(),
        data: (doc) => doc == null
            ? const _MissingDocument()
            : _Body(
                document: doc,
                pages: ref
                        .watch(_documentPagesProvider(documentId))
                        .value ??
                    const [],
              ),
      ),
    );
  }
}

class _MissingDocument extends StatelessWidget {
  const _MissingDocument();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return EmptyState(
      icon: Icons.description_outlined,
      title: l10n.documentNotFoundTitle,
      message: l10n.documentNotFoundMessage,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.document, required this.pages});

  final Document document;
  final List<DocumentPage> pages;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final tags = (jsonDecode(document.tagsJson) as List<dynamic>)
        .whereType<String>()
        .toList();
    final pagePaths = [
      for (final page in pages)
        if (File(page.originalPath).existsSync()) page.originalPath,
    ];
    final hasImage = document.originalPath.isNotEmpty &&
        File(document.originalPath).existsSync();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
      children: [
        Text(document.title, style: typo.pageTitle.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          [
            document.type.localizedLabel(l10n),
            if (document.hospital.isNotEmpty) document.hospital,
            if (document.doctor.isNotEmpty) document.doctor,
            document.documentDate.monthDayYear,
          ].join(' · '),
          style: typo.bodySmall.copyWith(color: colors.muted),
        ),
        const SizedBox(height: 14),
        if (pagePaths.length > 1)
          _PageGallery(paths: pagePaths)
        else if (hasImage)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.file(File(document.originalPath)),
            ),
          )
        else
          DocumentPaperPreview(type: document.type, height: 220),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                StatusChip(label: tag, tone: StatusTone.accent),
            ],
          ),
        ],
        if (document.ocrText.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            l10n.extractedText,
            style: typo.overline.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardTranslucent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Text(
              document.ocrText,
              style: typo.body.copyWith(color: colors.ink),
            ),
          ),
        ],
      ],
    );
  }
}

/// Swipeable pages of an imported multi-page document, with an "n/N" pill.
class _PageGallery extends StatefulWidget {
  const _PageGallery({required this.paths});

  final List<String> paths;

  @override
  State<_PageGallery> createState() => _PageGalleryState();
}

class _PageGalleryState extends State<_PageGallery> {
  var _current = 0;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 420,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.paths.length,
              onPageChanged: (index) => setState(() => _current = index),
              itemBuilder: (context, index) => InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Image.file(File(widget.paths[index])),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${_current + 1}/${widget.paths.length}',
                  style: typo.caption.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
