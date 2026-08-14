import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../settings/presentation/controllers/theme_controller.dart';

/// Brand + patient identity row with the theme toggle and avatar.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key, required this.patient});

  final Patient? patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      colors.brandGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    'KidneyCare',
                    style: typo.sectionTitle.copyWith(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  patient == null
                      ? l10n.settingUpVault
                      : '${patient!.name} · ${patient!.age} · '
                          '${patient!.conditionSummary}',
                  style: typo.bodySmall.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: isDark
                ? l10n.switchToLightTheme
                : l10n.switchToDarkTheme,
            child: InkWell(
              onTap: () =>
                  ref.read(themeModeProvider.notifier).toggle(brightness),
              customBorder: const CircleBorder(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: colors.cardShadow,
                ),
                child: Icon(
                  isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                  size: 17,
                  color: colors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Semantics(
            button: true,
            label: l10n.openSettings,
            child: InkWell(
              onTap: () => context.pushNamed('settings'),
              customBorder: const CircleBorder(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  patient?.initials ?? '·',
                  style: typo.caption.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.onAccent,
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
