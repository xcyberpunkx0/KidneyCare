import 'package:flutter/material.dart';

import '../l10n/l10n_x.dart';
import '../theme/app_colors.dart';

/// The small ⋮ at the right edge of an editable card. Cards keep their
/// long-press shortcut, but this button is the visible way into the
/// edit/delete menu.
class CardMoreButton extends StatelessWidget {
  const CardMoreButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.moreOptions,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.more_vert,
            size: 20,
            color: context.colors.muted,
          ),
        ),
      ),
    );
  }
}
