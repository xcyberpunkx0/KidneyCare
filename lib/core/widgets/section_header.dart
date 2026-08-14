import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// In-page section title row: bold label left, optional muted note or
/// accent-colored action on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingNote,
    this.actionLabel,
    this.onAction,
  });

  final String title;

  /// Muted informational note, e.g. "2 of 5 given".
  final String? trailingNote;

  /// Accent-colored tappable action, e.g. "See all".
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gutter,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(title, style: typo.sectionTitle)),
          if (trailingNote != null)
            Text(
              trailingNote!,
              style: typo.caption
                  .copyWith(fontSize: 11.5, color: colors.muted),
            ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  actionLabel!,
                  style: typo.caption.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
