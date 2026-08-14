import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/repository_impl/documents_repository_impl.dart';
import '../widgets/document_paper_preview.dart';

final _documentByIdProvider =
    FutureProvider.family<Document?, String>((ref, id) {
  return ref.watch(documentsRepositoryProvider).getById(id);
});

/// Full-screen document view: original scan (or placeholder), metadata and
/// extracted text.
class DocumentViewerPage extends ConsumerWidget {
  const DocumentViewerPage({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final document = ref.watch(_documentByIdProvider(documentId));

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: document.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _MissingDocument(),
        data: (doc) =>
            doc == null ? const _MissingDocument() : _Body(document: doc),
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
  const _Body({required this.document});

  final Document document;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final tags = (jsonDecode(document.tagsJson) as List<dynamic>)
        .whereType<String>()
        .toList();
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
        if (hasImage)
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
