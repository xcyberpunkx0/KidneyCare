import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/domain/document_type.dart';

/// Two-column grid of document folders with tinted folder icons and file
/// counts.
class FoldersGrid extends StatelessWidget {
  const FoldersGrid({
    super.key,
    required this.counts,
    required this.onOpenFolder,
  });

  final Map<DocumentType, int> counts;
  final void Function(DocumentType type) onOpenFolder;

  static const _folders = [
    DocumentType.labReport,
    DocumentType.prescription,
    DocumentType.dischargeSummary,
    DocumentType.bill,
  ];

  String _label(AppLocalizations l10n, DocumentType type) =>
      switch (type) {
        DocumentType.labReport => l10n.folderLabReports,
        DocumentType.prescription => l10n.folderPrescriptions,
        DocumentType.dischargeSummary => l10n.folderDischarge,
        _ => l10n.folderBills,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    (Color, Color) tint(DocumentType type) => switch (type) {
          DocumentType.labReport => (colors.amberChip, colors.amberDot),
          DocumentType.prescription => (colors.greenBg, colors.green),
          DocumentType.dischargeSummary => (colors.blueBg, colors.blue),
          _ => (colors.purpleBg, colors.purple),
        };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _folders.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 62,
        ),
        itemBuilder: (context, index) {
          final type = _folders[index];
          final label = _label(l10n, type);
          final (chipBg, iconColor) = tint(type);
          final count = counts[type] ?? 0;

          return AppCard(
            onTap: () => onOpenFolder(type),
            semanticLabel: l10n.folderSemantics(label, count),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.folder, size: 15, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.bodySmall.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        l10n.folderFiles(count),
                        style: typo.caption.copyWith(
                          fontSize: 10.5,
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
