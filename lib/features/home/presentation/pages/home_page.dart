import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_shell.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/capture_button.dart';
import '../../../../core/widgets/record_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../claims/presentation/widgets/claims_glance_card.dart';
import '../../../patient/data/repository_impl/patient_repository_impl.dart';
import '../controllers/home_providers.dart';
import '../widgets/attention_card.dart';
import '../widgets/dialysis_hero_card.dart';
import '../widgets/dose_strip.dart';
import '../widgets/due_meds_card.dart';
import '../widgets/folders_grid.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/vitals_grid.dart';

/// Home — the caregiver's pinned summary: attention items, vitals, next
/// dialysis, today's doses, folders and recent records.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final patient = ref.watch(patientProvider).value;
    final snapshot = ref.watch(vitalsSnapshotProvider);
    final nextDialysis = ref.watch(nextDialysisProvider).value;
    final lastDialysis = ref.watch(lastDialysisProvider).value;
    final doses = ref.watch(todaysDosesProvider).value ?? const [];
    final recent = ref.watch(recentEventsProvider).value ?? const [];
    final docCounts = ref.watch(documentCountsProvider).value ?? const {};

    final takenCount = doses.where((d) => d.taken).length;

    return Scaffold(
      backgroundColor: colors.bgHome,
      floatingActionButton: const CaptureButton(),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppShell.navClearance),
          children: [
            HomeHeader(patient: patient),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: AppSearchBar(
                hint: l10n.homeSearchHint,
                onTap: () => context.push(AppRoutes.search),
              ),
            ),
            ...snapshot.when(
              loading: () => const [SizedBox(height: 180)],
              error: (_, _) => const [SizedBox.shrink()],
              data: (data) => [
                AttentionCard(
                  items: data.attention,
                  onItemTap: (item) => _openMetric(context, item.metricCode),
                ),
                VitalsGrid(
                  readings: data.tiles,
                  onTileTap: (tile) => _openMetric(context, tile.metricCode),
                ),
              ],
            ),
            const DueMedsCard(),
            GestureDetector(
              onTap: () => context.go(AppRoutes.dialysis),
              child: DialysisHeroCard(next: nextDialysis, last: lastDialysis),
            ),
            const QuickActionsRow(),
            const ClaimsGlanceCard(),
            SectionHeader(
              title: l10n.todaysDoses,
              trailingNote: doses.isEmpty
                  ? null
                  : l10n.dosesGiven(takenCount, doses.length),
            ),
            if (doses.isNotEmpty)
              DoseStrip(
                doses: doses,
                onToggle: (dose) => _toggleDose(context, ref, dose),
              ),
            SectionHeader(
              title: l10n.folders,
              actionLabel: l10n.allDocuments,
              onAction: () => context.pushNamed(AppRoutes.documentsName),
            ),
            FoldersGrid(
              counts: docCounts,
              onOpenFolder: (type) => context.pushNamed(
                AppRoutes.documentsName,
                queryParameters: {'type': type.name},
              ),
            ),
            SectionHeader(
              title: l10n.recentRecords,
              actionLabel: l10n.seeAll,
              onAction: () => context.pushNamed(AppRoutes.timelineName),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Column(
                children: [
                  for (final event in recent) ...[
                    RecordTile(
                      type: event.type,
                      title: event.title,
                      subtitle: event.subtitle,
                      dateLabel: event.occurredAt.monthDay,
                      onTap: () => context.pushNamed(AppRoutes.timelineName),
                    ),
                    const SizedBox(height: 7),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Flips a dose chip and confirms it with an undo — a mistaken tap is
  /// reversed from the snackbar instead of hunting the chip again.
  Future<void> _toggleDose(
    BuildContext context,
    WidgetRef ref,
    Dose dose,
  ) async {
    final l10n = context.l10n;
    await ref.read(doseToggleProvider)(dose);
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      dose.taken
          ? l10n.doseMarkedNotGiven(dose.medicationLabel)
          : l10n.doseMarkedGiven(dose.medicationLabel),
      actionLabel: l10n.undo,
      onAction: () =>
          ref.read(doseToggleProvider)(dose.copyWith(taken: !dose.taken)),
    );
  }

  void _openMetric(BuildContext context, String? metricCode) {
    if (metricCode == null) return;
    context.go(
      Uri(
        path: AppRoutes.labs,
        queryParameters: {'metric': metricCode},
      ).toString(),
    );
  }
}
