import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n_x.dart';
import '../router/routes.dart';
import '../theme/app_colors.dart';

/// The capture button, floated by screens where adding a document is the
/// natural next step (home, documents library) — not globally, so it
/// never covers other screens' actions.
class CaptureButton extends StatelessWidget {
  const CaptureButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      // Page scaffolds sit inside the shell, whose floating nav pill is
      // unknown to them — lift the button clear of it.
      padding: const EdgeInsets.only(bottom: 92),
      child: Semantics(
        button: true,
        label: context.l10n.captureDocument,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.accent,
            shape: BoxShape.circle,
            boxShadow: colors.fabGlow,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => context.push(AppRoutes.capture),
              customBorder: const CircleBorder(),
              child: Icon(
                Icons.photo_camera_outlined,
                size: 24,
                color: colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
