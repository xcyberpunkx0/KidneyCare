import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/repository_impl/medications_repository_impl.dart';
import '../../domain/usecases/interval_due.dart';
import 'medication_actions_sheet.dart';

/// Checklist card for an every-few-days medicine: due status plus a
/// tick to mark it given today (tap again the same day to undo).
/// Long-press opens the edit/end/delete menu like other medicine cards.
class IntervalMedCard extends ConsumerWidget {
  const IntervalMedCard({super.key, required this.medication});

  final Medication medication;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final repo = ref.read(medicationsRepositoryProvider);
    final now = DateTime.now();
    final given = medication.wasGivenOn(now);
    if (given) {
      await repo.undoGiven(medication.id, now);
    } else {
      await repo.markGiven(medication.id, now);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            given
                ? l10n.doseMarkedNotGiven(medication.name)
                : l10n.doseMarkedGiven(medication.name),
          ),
          action: given
              ? null
              : SnackBarAction(
                  label: l10n.undo,
                  onPressed: () =>
                      repo.undoGiven(medication.id, DateTime.now()),
                ),
        ),
      );
  }

  StatusChip _statusChip(BuildContext context, DateTime today) {
    final l10n = context.l10n;
    if (medication.wasGivenOn(today)) {
      return StatusChip(label: l10n.givenToday, tone: StatusTone.green);
    }
    final overdue = medication.overdueDaysOn(today);
    if (overdue > 0) {
      return StatusChip(
        label: l10n.overdueByDays(overdue),
        tone: StatusTone.critical,
      );
    }
    if (medication.isDueOn(today)) {
      return StatusChip(label: l10n.dueToday, tone: StatusTone.amber);
    }
    return StatusChip(
      label: l10n.nextOnDate(medication.nextDueOn(today)!.monthDay),
      tone: StatusTone.neutral,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final today = DateTime.now();
    final given = medication.wasGivenOn(today);

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
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.purpleBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.vaccines_outlined,
                size: 18,
                color: colors.purple,
              ),
            ),
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
                      l10n.everyNDays(medication.intervalDays!),
                      if (medication.purpose.isNotEmpty) medication.purpose,
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typo.bodySmall.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 6),
                  _statusChip(context, today),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              checked: given,
              label: l10n.markGivenSemantics(medication.name),
              child: InkWell(
                onTap: () => _toggle(context, ref),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    given ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 30,
                    color: given ? colors.green : colors.muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
