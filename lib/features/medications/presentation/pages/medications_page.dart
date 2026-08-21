import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../shared/domain/med_schedule.dart';
import '../../data/repository_impl/medications_repository_impl.dart';
import '../../domain/usecases/interval_due.dart';
import '../controllers/medications_controllers.dart';
import '../widgets/ended_meds_section.dart';
import '../widgets/interval_med_card.dart';
import '../widgets/medication_card.dart';

/// Medicines — active medications grouped by schedule, with a collapsible
/// ended-medicines section.
class MedicationsPage extends ConsumerWidget {
  const MedicationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final active = ref.watch(activeMedicationsProvider).value ?? const [];
    final ended = ref.watch(endedMedicationsProvider).value ?? const [];
    final showEnded = ref.watch(showEndedProvider);

    final interval = active.where((m) => m.isIntervalMed).toList();
    final rest = active.where((m) => !m.isIntervalMed).toList();
    final dialysisDays = rest
        .where((m) => m.frequency == MedFrequency.dialysisDaysOnly)
        .toList();
    final weekly =
        rest.where((m) => m.frequency == MedFrequency.weekly).toList();
    final aroundMeals = rest
        .where(
          (m) =>
              m.frequency == MedFrequency.daily &&
              m.foodRelation != MedFoodRelation.noRelation,
        )
        .toList();
    final byClock = rest
        .where(
          (m) =>
              !dialysisDays.contains(m) &&
              !weekly.contains(m) &&
              !aroundMeals.contains(m),
        )
        .toList();

    return Scaffold(
      backgroundColor: colors.bgSection,
      body: SafeArea(
        bottom: false,
        child: active.isEmpty && ended.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmptyState(
                    icon: Icons.medication_outlined,
                    title: l10n.noMedicinesTitle,
                    message: l10n.noMedicinesMessage,
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed('addMedication'),
                    child: Text(
                      l10n.addMedicineManually,
                      style: typo.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: AppShell.navClearance),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.medicines,
                            style: typo.pageTitle.copyWith(fontSize: 25),
                          ),
                        ),
                        Text(
                          l10n.nActive(active.length),
                          style: typo.bodySmall.copyWith(color: colors.muted),
                        ),
                        const SizedBox(width: 10),
                        const _AddMedicineButton(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (interval.isNotEmpty) ...[
                          _GroupLabel(label: l10n.intervalGroup),
                          for (final med in interval) ...[
                            IntervalMedCard(medication: med),
                            const SizedBox(height: 9),
                          ],
                        ],
                        if (dialysisDays.isNotEmpty) ...[
                          _GroupLabel(label: l10n.dialysisDaysGroup),
                          for (final med in dialysisDays) ...[
                            MedicationCard(medication: med),
                            const SizedBox(height: 9),
                          ],
                        ],
                        if (weekly.isNotEmpty) ...[
                          _GroupLabel(label: l10n.weeklyGroup),
                          for (final med in weekly) ...[
                            MedicationCard(medication: med),
                            const SizedBox(height: 9),
                          ],
                        ],
                        if (aroundMeals.isNotEmpty) ...[
                          _GroupLabel(label: l10n.aroundMealsGroup),
                          for (final med in aroundMeals) ...[
                            MedicationCard(medication: med),
                            const SizedBox(height: 9),
                          ],
                        ],
                        if (byClock.isNotEmpty) ...[
                          _GroupLabel(label: l10n.byTheClockGroup),
                          for (final med in byClock) ...[
                            MedicationCard(medication: med),
                            const SizedBox(height: 9),
                          ],
                        ],
                        EndedMedsSection(
                          medications: ended,
                          expanded: showEnded,
                          onToggle: () =>
                              ref.read(showEndedProvider.notifier).toggle(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 9),
      child: Text(
        label,
        style: context.typo.overline.copyWith(
          fontSize: 11,
          letterSpacing: 0.88,
          color: context.colors.muted,
        ),
      ),
    );
  }
}

/// Small accent pill opening the manual medicine form.
class _AddMedicineButton extends StatelessWidget {
  const _AddMedicineButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.addMedicineManually,
      child: Material(
        color: colors.accentSoft,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: () => context.pushNamed('addMedication'),
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 14, color: colors.onAccentSoft),
                const SizedBox(width: 3),
                Text(
                  l10n.add,
                  style: context.typo.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onAccentSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
