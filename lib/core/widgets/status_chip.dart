import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Semantic tone of a [StatusChip].
enum StatusTone { neutral, accent, amber, green, blue, purple, critical }

/// Small rounded label chip, e.g. "below range", "dose ↑ Jul 28".
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    final (bg, fg) = switch (tone) {
      StatusTone.neutral => (colors.divider, colors.muted),
      StatusTone.accent => (colors.accentSoft, colors.onAccentSoft),
      StatusTone.amber => (colors.amberChip, colors.amber),
      StatusTone.green => (colors.greenBg, colors.green),
      StatusTone.blue => (colors.blueBg, colors.blue),
      StatusTone.purple => (colors.purpleBg, colors.purple),
      StatusTone.critical => (colors.criticalBg, colors.critical),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: typo.caption.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
