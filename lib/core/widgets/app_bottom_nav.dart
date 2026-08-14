import 'package:flutter/material.dart';

import '../l10n/l10n_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Destination tabs of the floating pill navigation, in visual order.
enum AppTab { home, labs, dialysis, medications, ask }

/// Floating pill bottom bar with five equal destinations. Capture lives
/// on a separate corner button owned by the shell.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  static const _icons = {
    AppTab.home: Icons.home_outlined,
    AppTab.labs: Icons.show_chart,
    AppTab.dialysis: Icons.water_drop_outlined,
    AppTab.medications: Icons.medication_outlined,
    AppTab.ask: Icons.chat_bubble_outline,
  };

  String _label(AppLocalizations l10n, AppTab tab) => switch (tab) {
        AppTab.home => l10n.navHome,
        AppTab.labs => l10n.navLabs,
        AppTab.dialysis => l10n.navDialysis,
        AppTab.medications => l10n.navMedicines,
        AppTab.ask => l10n.navAsk,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, AppSpacing.sm, 18, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: colors.navBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: colors.cardBorder),
          boxShadow: colors.navShadow,
        ),
        child: Row(
          children: [
            for (final tab in AppTab.values)
              _NavIcon(
                icon: _icons[tab]!,
                label: _label(l10n, tab),
                selected: current == tab,
                onTap: () => onSelect(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: 44,
            child: Center(
              child: selected
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Icon(
                        icon,
                        size: AppIconSize.lg,
                        color: colors.onAccentSoft,
                      ),
                    )
                  : Icon(
                      icon,
                      size: AppIconSize.lg,
                      color: colors.muted,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
