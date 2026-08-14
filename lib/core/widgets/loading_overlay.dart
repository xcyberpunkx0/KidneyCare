import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Reassuring blocking overlay for long-running work, e.g.
/// "Extracting information…".
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return ColoredBox(
      color: colors.ink.withValues(alpha: 0.25),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppRadius.attention),
            boxShadow: colors.navShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(message, style: typo.body.copyWith(color: colors.ink)),
            ],
          ),
        ),
      ),
    );
  }
}
