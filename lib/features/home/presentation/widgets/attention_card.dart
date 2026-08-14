import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/vital_reading.dart';

/// Amber "needs attention" card. Absent entirely when nothing is off —
/// silence is the calm state.
class AttentionCard extends StatelessWidget {
  const AttentionCard({super.key, required this.items, this.onItemTap});

  final List<AttentionItem> items;
  final void Function(AttentionItem item)? onItemTap;

  String _note(AppLocalizations l10n, AttentionItem item) =>
      switch (item.reason) {
        AttentionReason.belowRangeRecheck => l10n.attentionBelowRecheck,
        AttentionReason.fallingStreak =>
          l10n.attentionFallingMonths(item.fallingMonths),
        AttentionReason.aboveRangeDiet => l10n.attentionAboveDiet,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.amberBg,
        borderRadius: BorderRadius.circular(AppRadius.attention),
        border: Border.all(color: colors.amberBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.needsAttention(items.length),
                style: typo.overline.copyWith(
                  fontSize: 11,
                  color: colors.amber,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.amberDot,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.amberBorder),
            InkWell(
              onTap:
                  onItemTap == null ? null : () => onItemTap!(items[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 58),
                      child: Text(
                        items[i].shortValue,
                        style: typo
                            .number(13, color: colors.amber)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _note(l10n, items[i]),
                        style: typo.bodySmall.copyWith(
                          fontSize: 12.5,
                          color: colors.ink.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
