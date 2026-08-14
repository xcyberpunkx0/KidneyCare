import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Labeled input card in the style of the review screen's field cards.
///
/// Shared by the patient setup, manual lab entry and manual medicine forms.
class LabeledFieldCard extends StatelessWidget {
  const LabeledFieldCard({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.hint,
    this.child,
  }) : assert(controller != null || child != null,
            'Provide a controller for a text field or a custom child');

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hint;

  /// Custom content (e.g. chips) instead of a text field.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardTranslucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typo.caption.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.42,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 6),
          child ??
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: typo.cardTitle.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.ink,
                ),
                cursorColor: colors.accent,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: colors.fieldBg,
                  hintText: hint,
                  hintStyle: typo.cardTitle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.muted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: colors.fieldBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: colors.accent, width: 1.5),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
