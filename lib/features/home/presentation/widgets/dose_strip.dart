import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// Horizontally scrolling strip of today's dose chips. The first pending
/// dose is highlighted as "NEXT"; taken doses fade back.
class DoseStrip extends StatelessWidget {
  const DoseStrip({super.key, required this.doses, required this.onToggle});

  final List<Dose> doses;
  final void Function(Dose dose) onToggle;

  @override
  Widget build(BuildContext context) {
    final nextPendingIndex = doses.indexWhere((d) => !d.taken);

    return SizedBox(
      height: 66,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        scrollDirection: Axis.horizontal,
        itemCount: doses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) => _DoseChip(
          dose: doses[index],
          isNext: index == nextPendingIndex,
          onTap: () => onToggle(doses[index]),
        ),
      ),
    );
  }
}

class _DoseChip extends StatelessWidget {
  const _DoseChip({
    required this.dose,
    required this.isNext,
    required this.onTap,
  });

  final Dose dose;
  final bool isNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    final (timeText, timeColor) = dose.taken
        ? ('✓ ${dose.timeLabel}', colors.green)
        : isNext
            ? (l10n.doseNext(dose.timeLabel), colors.onAccentSoft)
            : (dose.timeLabel, colors.muted);

    return Semantics(
      button: true,
      label: dose.taken
          ? l10n.doseTaken(dose.medicationLabel, dose.timeLabel)
          : l10n.doseMark(dose.medicationLabel, dose.timeLabel),
      child: Opacity(
        opacity: dose.taken ? 0.6 : 1,
        child: Material(
          color: isNext ? colors.accentSoft : colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.doseChip),
            side: isNext
                ? BorderSide(color: colors.accentSoftBorder, width: 1.5)
                : BorderSide(color: colors.cardBorder),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.doseChip),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: typo.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: timeColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dose.medicationLabel,
                    style: typo.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
