import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/document_type.dart';
import 'camera_step.dart';

/// First step of the capture flow: the caregiver says what the document
/// is before the camera opens. Lab reports get AI reading; every other
/// type is stored exactly as photographed.
class TypePickStep extends StatelessWidget {
  const TypePickStep({
    super.key,
    required this.onCancel,
    required this.onSelect,
  });

  final VoidCallback onCancel;
  final ValueChanged<DocumentType> onSelect;

  /// Icons per document type, shared with the batch setup tiles.
  static const icons = {
    DocumentType.labReport: Icons.science_outlined,
    DocumentType.prescription: Icons.medication_outlined,
    DocumentType.dischargeSummary: Icons.assignment_outlined,
    DocumentType.bill: Icons.receipt_long_outlined,
    DocumentType.handwrittenNote: Icons.edit_note,
    DocumentType.scan: Icons.document_scanner_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 14, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close, color: CaptureChrome.ink),
              ),
              Expanded(
                child: Text(
                  l10n.whatIsThisDocument,
                  style: typo.pageTitle.copyWith(
                    fontSize: 20,
                    color: CaptureChrome.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
          child: Text(
            l10n.typePickAiHint,
            style: typo.bodySmall.copyWith(color: CaptureChrome.frame),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            itemCount: DocumentType.values.length,
            separatorBuilder: (_, _) => const SizedBox(height: 9),
            itemBuilder: (context, index) {
              final type = DocumentType.values[index];
              return Semantics(
                button: true,
                label: type.localizedLabel(l10n),
                child: Material(
                  color: CaptureChrome.pillBg,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => onSelect(type),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CaptureChrome.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(icons[type],
                              size: 22, color: CaptureChrome.ink),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              type.localizedLabel(l10n),
                              style: typo.cardTitle.copyWith(
                                fontSize: 15,
                                color: CaptureChrome.ink,
                              ),
                            ),
                          ),
                          if (type == DocumentType.labReport)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: CaptureChrome.pillBg,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color: CaptureChrome.outline),
                              ),
                              child: Text(
                                l10n.aiReadBadge,
                                style: typo.caption.copyWith(
                                  fontSize: 10,
                                  color: CaptureChrome.ink,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
