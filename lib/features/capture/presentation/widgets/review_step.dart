import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../controllers/review_draft.dart';
import 'review_field_card.dart';

/// The trust screen: every extracted field, editable, with confidence
/// indicators. Saving stays blocked until each uncertain field is checked.
/// Shared by the single capture flow and the batch import queue; batch
/// mode adds a [header] (queue progress) and its own [saveLabel].
class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.draft,
    required this.saving,
    this.header,
    this.saveLabel,
    required this.onEdit,
    required this.onChooseAlternative,
    required this.onSave,
  });

  final ReviewDraft draft;
  final bool saving;
  final Widget? header;
  final String? saveLabel;
  final void Function(String key, String value) onEdit;
  final void Function(String key, String value) onChooseAlternative;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final extraction = draft.extraction;
    final fields = draft.reviewFields;
    final unchecked = draft.uncheckedCount;

    return Container(
      color: colors.bgSection,
      child: Column(
        children: [
          ?header,
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reviewExtraction,
                    style: typo.pageTitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      extraction.documentType.localizedLabel(l10n),
                      if (extraction.hospital.isNotEmpty)
                        extraction.hospital,
                      extraction.documentDate.monthDay,
                      l10n.fieldsRead(fields.length),
                    ].join(' · '),
                    style: typo.caption.copyWith(
                      fontSize: 11.5,
                      color: colors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: unchecked > 0 ? colors.amberBg : colors.greenBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    unchecked > 0 ? colors.amberBorder : colors.greenBg,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        unchecked > 0 ? colors.amberDot : colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    unchecked > 0
                        ? l10n.fieldsNeedCheck(unchecked, fields.length)
                        : l10n.allFieldsChecked,
                    style: typo.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: unchecked > 0 ? colors.amber : colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              itemCount: fields.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final field = fields[index];
                return ReviewFieldCard(
                  field: field,
                  checked: draft.isChecked(field),
                  onChanged: (value) => onEdit(field.key, value),
                  onChooseAlternative: (value) =>
                      onChooseAlternative(field.key, value),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Semantics(
                button: true,
                enabled: !saving,
                label: saveLabel ?? l10n.saveToTimeline,
                child: Material(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(99),
                  child: InkWell(
                    onTap: saving ? null : onSave,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          saving
                              ? l10n.saving
                              : saveLabel ?? l10n.saveToTimeline,
                          style: typo.cardTitle.copyWith(
                            fontSize: 15,
                            color: colors.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
