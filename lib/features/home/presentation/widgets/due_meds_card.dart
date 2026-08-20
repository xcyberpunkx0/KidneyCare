import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../medications/data/repository_impl/medications_repository_impl.dart';
import '../../../medications/domain/usecases/interval_due.dart';

/// Amber card listing every-few-days medicines that are due or overdue
/// today, each with a one-tap "mark given". Absent when nothing is due.
class DueMedsCard extends ConsumerWidget {
  const DueMedsCard({super.key});

  Future<void> _markGiven(
    BuildContext context,
    WidgetRef ref,
    Medication med,
  ) async {
    final l10n = context.l10n;
    final repo = ref.read(medicationsRepositoryProvider);
    await repo.markGiven(med.id, DateTime.now());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.doseMarkedGiven(med.name)),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => repo.undoGiven(med.id, DateTime.now()),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final today = DateTime.now();
    final due = (ref.watch(activeMedicationsProvider).value ?? const [])
        .where((m) => m.isDueOn(today) && !m.wasGivenOn(today))
        .toList();

    if (due.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.amberBg,
        borderRadius: BorderRadius.circular(AppRadius.attention),
        border: Border.all(color: colors.amberBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.medicinesDue,
                style: typo.overline.copyWith(
                  fontSize: 11,
                  color: colors.amber,
                ),
              ),
              Icon(Icons.vaccines_outlined, size: 14, color: colors.amber),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < due.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.amberBorder),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        due[i].name,
                        style: typo.cardTitle.copyWith(fontSize: 13.5),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        due[i].overdueDaysOn(today) > 0
                            ? l10n.overdueByDays(due[i].overdueDaysOn(today))
                            : l10n.dueToday,
                        style: typo.bodySmall.copyWith(
                          fontSize: 12,
                          color: due[i].overdueDaysOn(today) > 0
                              ? colors.critical
                              : colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _markGiven(context, ref, due[i]),
                  child: Text(
                    l10n.markGivenToday,
                    style: typo.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
