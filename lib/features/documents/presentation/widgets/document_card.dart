import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../shared/domain/document_type.dart';
import 'document_paper_preview.dart';

/// Grid card for one document: preview, type badge, date, title, source.
class DocumentCard extends StatelessWidget {
  const DocumentCard({super.key, required this.document, this.onTap});

  final Document document;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final (badge, badgeBg, badgeFg) = _badge(colors);

    return Semantics(
      button: true,
      label: '${document.type.localizedLabel(l10n)}: ${document.title}, '
          '${document.documentDate.monthDayYear}',
      child: Material(
        color: colors.cardTranslucent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.cardBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DocumentPaperPreview(
                  type: document.type,
                  previewPath: document.previewPath,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              badge,
                              style: typo.caption.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: badgeFg,
                              ),
                            ),
                          ),
                          Text(
                            document.documentDate.monthDay,
                            style: typo.caption.copyWith(
                              fontSize: 10,
                              color: colors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        _sourceLine(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.caption.copyWith(
                          fontSize: 10,
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _sourceLine(AppLocalizations l10n) {
    final parts = [
      if (document.doctor.isNotEmpty) document.doctor,
      if (document.hospital.isNotEmpty) document.hospital,
    ];
    return parts.isEmpty
        ? document.type.localizedLabel(l10n)
        : parts.join(' · ');
  }

  (String, Color, Color) _badge(AppColors colors) {
    return switch (document.type) {
      DocumentType.labReport => ('LAB', colors.amberChip, colors.amber),
      DocumentType.prescription => ('RX', colors.greenBg, colors.green),
      DocumentType.dischargeSummary =>
        ('DISCHARGE', colors.blueBg, colors.blue),
      DocumentType.bill => ('BILL', colors.purpleBg, colors.purple),
      DocumentType.handwrittenNote =>
        ('NOTE', colors.greenBg, colors.green),
      DocumentType.scan => ('SCAN', colors.blueBg, colors.blue),
    };
  }
}
