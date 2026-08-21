import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/card_more_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/domain/med_schedule.dart';
import 'medication_actions_sheet.dart';

/// One active medication card: timing chip, name, purpose/schedule line,
/// and the dose pattern (or a dose-change badge). The ⋮ button (or a
/// long-press anywhere on the card) opens the edit/end/delete menu.
class MedicationCard extends ConsumerWidget {
  const MedicationCard({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;

    return GestureDetector(
      onLongPress: () => showMedicationActions(context, ref, medication),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.cardTranslucent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          children: [
            _LeadingChip(medication: medication),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: typo.cardTitle.copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      medication.purpose,
                      if (medication.scheduleNote.isNotEmpty)
                        medication.scheduleNote,
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typo.bodySmall.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (medication.changeNote.isNotEmpty &&
                medication.changeDate != null)
              StatusChip(
                label:
                    '${medication.changeNote} '
                    '${DateFormat('MMM d').format(medication.changeDate!)}',
                tone: StatusTone.amber,
              )
            else
              Text(
                medication.frequencyCode,
                style: typo.number(
                  13,
                  weight: FontWeight.w600,
                  color: _scheduleTone(medication, colors).$2,
                ),
              ),
            const SizedBox(width: 4),
            CardMoreButton(
              onTap: () => showMedicationActions(context, ref, medication),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip palette: purple for weekly/dialysis rhythms, green for
/// meal-anchored daily medicines, blue for the rest (clock-timed).
(Color, Color) _scheduleTone(Medication medication, AppColors colors) {
  if (medication.frequency != MedFrequency.daily) {
    return (colors.purpleBg, colors.purple);
  }
  if (medication.foodRelation != MedFoodRelation.noRelation) {
    return (colors.greenBg, colors.green);
  }
  return (colors.blueBg, colors.blue);
}

class _LeadingChip extends StatelessWidget {
  const _LeadingChip({required this.medication});

  final Medication medication;

  List<MedTimeOfDay> get _times {
    final raw = jsonDecode(medication.timeOfDayJson);
    if (raw is! List) return const [];
    return [
      for (final name in raw.whereType<String>())
        if (MedTimeOfDay.values.asNameMap().containsKey(name))
          MedTimeOfDay.values.byName(name),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final times = _times;
    final (bg, fg) = _scheduleTone(medication, colors);

    Widget content;
    final smallLabel = _smallLabel(times);
    if (smallLabel != null) {
      content = Text(
        smallLabel,
        textAlign: TextAlign.center,
        style: typo.caption.copyWith(
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      );
    } else {
      content = Icon(_icon(times), size: 18, color: fg);
    }

    final l10n = context.l10n;
    return Tooltip(
      message: [
        medication.frequency.localizedLabel(l10n),
        if (medication.foodRelation != MedFoodRelation.noRelation)
          medication.foodRelation.localizedLabel(l10n),
        for (final time in times) time.localizedLabel(l10n),
      ].join(', '),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: content,
      ),
    );
  }

  /// Compact text for chips that read better as words than icons:
  /// dialysis days ("HD") and clock times for un-anchored daily doses.
  String? _smallLabel(List<MedTimeOfDay> times) {
    if (medication.frequency == MedFrequency.dialysisDaysOnly) return 'HD';
    if (medication.frequency == MedFrequency.daily &&
        medication.foodRelation == MedFoodRelation.noRelation) {
      if (times.contains(MedTimeOfDay.morning)) return '7 AM';
      if (times.contains(MedTimeOfDay.noon)) return '12 PM';
      if (times.contains(MedTimeOfDay.night)) return '9 PM';
    }
    return null;
  }

  IconData _icon(List<MedTimeOfDay> times) {
    if (medication.frequency == MedFrequency.weekly) {
      return Icons.event_repeat_outlined;
    }
    switch (medication.foodRelation) {
      case MedFoodRelation.beforeFood:
        return Icons.no_meals_outlined;
      case MedFoodRelation.afterFood:
        return Icons.restaurant_outlined;
      case MedFoodRelation.withFood:
        return Icons.medication_outlined;
      case MedFoodRelation.noRelation:
        break;
    }
    if (times.contains(MedTimeOfDay.night)) {
      return Icons.nightlight_outlined;
    }
    if (times.contains(MedTimeOfDay.morning)) {
      return Icons.wb_sunny_outlined;
    }
    if (times.contains(MedTimeOfDay.noon)) {
      return Icons.light_mode_outlined;
    }
    return Icons.medication_outlined;
  }
}
