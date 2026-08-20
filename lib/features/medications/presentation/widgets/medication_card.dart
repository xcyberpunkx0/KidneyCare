import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/domain/med_schedule.dart';
import 'medication_actions_sheet.dart';

/// One active medication card: timing chip, name, purpose/schedule line,
/// and the dose pattern (or a dose-change badge). Long-press opens the
/// edit/end/delete menu.
class MedicationCard extends ConsumerWidget {
  const MedicationCard({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final group = medication.scheduleGroup;

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
                  color: switch (group) {
                    MedScheduleGroup.withFood => colors.green,
                    MedScheduleGroup.byClock => colors.blue,
                    MedScheduleGroup.weekly => colors.purple,
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeadingChip extends StatelessWidget {
  const _LeadingChip({required this.medication});

  final Medication medication;

  List<MedTimingCue> get _cues {
    final raw = jsonDecode(medication.timingCuesJson);
    if (raw is! List) return const [];
    return [
      for (final name in raw.whereType<String>())
        if (MedTimingCue.values.asNameMap().containsKey(name))
          MedTimingCue.values.byName(name),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final cues = _cues;

    final (Color bg, Color fg) = switch (medication.scheduleGroup) {
      MedScheduleGroup.withFood => (colors.greenBg, colors.green),
      MedScheduleGroup.byClock => (colors.blueBg, colors.blue),
      MedScheduleGroup.weekly => (colors.purpleBg, colors.purple),
    };

    Widget content;
    if (medication.scheduleGroup == MedScheduleGroup.weekly) {
      content = Text(
        'WED\nHD',
        textAlign: TextAlign.center,
        style: typo.caption.copyWith(
          fontSize: 8.5,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      );
    } else if (medication.scheduleGroup == MedScheduleGroup.byClock &&
        _clockLabel(cues) != null) {
      content = Text(
        _clockLabel(cues)!,
        style: typo.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      );
    } else {
      content = Icon(_cueIcon(cues), size: 18, color: fg);
    }

    final l10n = context.l10n;
    return Tooltip(
      message: cues.map((c) => c.localizedLabel(l10n)).join(', '),
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

  String? _clockLabel(List<MedTimingCue> cues) {
    if (cues.contains(MedTimingCue.morning)) return '7 AM';
    if (cues.contains(MedTimingCue.noon)) return '12 PM';
    if (cues.contains(MedTimingCue.night)) return '9 PM';
    return null;
  }

  IconData _cueIcon(List<MedTimingCue> cues) {
    if (cues.contains(MedTimingCue.beforeFood)) {
      return Icons.no_meals_outlined;
    }
    if (cues.contains(MedTimingCue.afterFood)) {
      return Icons.restaurant_outlined;
    }
    if (cues.contains(MedTimingCue.withFood)) {
      return Icons.medication_outlined;
    }
    if (cues.contains(MedTimingCue.night)) {
      return Icons.nightlight_outlined;
    }
    if (cues.contains(MedTimingCue.morning)) {
      return Icons.wb_sunny_outlined;
    }
    if (cues.contains(MedTimingCue.noon)) {
      return Icons.light_mode_outlined;
    }
    return Icons.medication_outlined;
  }
}
