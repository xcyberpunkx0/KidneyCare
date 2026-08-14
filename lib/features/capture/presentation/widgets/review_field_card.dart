import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/extraction.dart';

/// One editable field on the review screen: label, confidence chip, input,
/// and — for uncertain reads — a helper note or alternative choices.
class ReviewFieldCard extends StatefulWidget {
  const ReviewFieldCard({
    super.key,
    required this.field,
    required this.checked,
    required this.onChanged,
    required this.onChooseAlternative,
  });

  final ExtractedField field;

  /// Whether this field no longer blocks saving.
  final bool checked;

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onChooseAlternative;

  @override
  State<ReviewFieldCard> createState() => _ReviewFieldCardState();
}

class _ReviewFieldCardState extends State<ReviewFieldCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.field.value);
  }

  @override
  void didUpdateWidget(covariant ReviewFieldCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.field.value != _controller.text) {
      _controller.text = widget.field.value;
    }
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
    final field = widget.field;
    final warn = field.level == ConfidenceLevel.low && !widget.checked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardTranslucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: warn ? colors.amberBorder : colors.cardBorder,
          width: warn ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field.label,
                style: typo.caption.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.42,
                  color: colors.muted,
                ),
              ),
              _ConfidenceChip(field: field, checked: widget.checked),
            ],
          ),
          const SizedBox(height: 5),
          Semantics(
            label: '${field.label} value',
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: typo.cardTitle.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.ink,
              ),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: warn ? colors.fieldWarnBg : colors.fieldBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                enabledBorder: _border(
                  warn ? colors.amberBorder : colors.fieldBorder,
                ),
                focusedBorder: _border(colors.accent),
              ),
            ),
          ),
          if (warn && field.note.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              field.note,
              style: typo.caption.copyWith(
                height: 1.4,
                color: colors.amber,
              ),
            ),
          ],
          if (warn && field.note.isEmpty) ...[
            const SizedBox(height: 5),
            Text(
              context.l10n.pleaseVerifyField,
              style: typo.caption.copyWith(
                height: 1.4,
                color: colors.amber,
              ),
            ),
          ],
          if (warn && field.alternatives.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _AlternativeButton(
                    label: '✓ ${field.value.split(' ').first}',
                    primary: true,
                    onTap: () => widget.onChooseAlternative(field.value),
                  ),
                ),
                for (final alternative in field.alternatives) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AlternativeButton(
                      label: alternative,
                      onTap: () =>
                          widget.onChooseAlternative(alternative),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({required this.field, required this.checked});

  final ExtractedField field;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final percent = (field.confidence * 100).round();

    final (String label, Color bg, Color fg) = checked
        ? (
            field.level == ConfidenceLevel.high
                ? '$percent%'
                : l10n.checkedChip,
            colors.greenBg,
            colors.green,
          )
        : (
            l10n.percentCheck(percent),
            colors.amberChip,
            colors.amber,
          );

    return Semantics(
      label: checked
          ? l10n.confidenceVerified(percent)
          : l10n.confidenceNeedsCheck(percent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: typo.caption.copyWith(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _AlternativeButton extends StatelessWidget {
  const _AlternativeButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Material(
      color: primary ? colors.accentSoft : colors.fieldBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: primary ? colors.accent : colors.fieldBorder,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: primary ? colors.onAccentSoft : colors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
