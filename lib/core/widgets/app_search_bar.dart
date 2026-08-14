import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Rounded search field on a card surface.
///
/// With [onTap] and no [controller] it acts as a passive entry point that
/// opens the search page; with a [controller] it is a live input.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final passive = controller == null && onChanged == null;

    final decoration = BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: colors.cardBorder),
      boxShadow: colors.cardShadow,
    );

    if (passive) {
      return Semantics(
        button: true,
        label: hint,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: AppTouch.minTarget,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: decoration,
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: colors.muted),
                const SizedBox(width: AppSpacing.sm + 2),
                Text(hint, style: typo.body.copyWith(color: colors.muted)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: AppTouch.minTarget,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: decoration,
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: colors.muted),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: autofocus,
              style: typo.body.copyWith(color: colors.ink),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: typo.body.copyWith(color: colors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
