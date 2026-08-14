import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Pill selector chip: dark "active" fill when selected, translucent card
/// when not. Used for lab metric switching and document filters.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: Material(
        color: selected ? colors.chipActive : colors.cardTranslucent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: selected
              ? BorderSide.none
              : BorderSide(color: colors.cardBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: SizedBox(
              height: 36,
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: typo.bodySmall.copyWith(
                    fontSize: 12.5,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? colors.onChipActive : colors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
