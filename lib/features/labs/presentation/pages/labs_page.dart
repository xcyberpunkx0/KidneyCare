import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_shell.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/repository_impl/labs_repository_impl.dart';
import '../controllers/labs_controllers.dart';
import '../widgets/all_values_card.dart';
import '../widgets/lab_chart_card.dart';
import '../widgets/metric_chip_row.dart';

/// Labs & Trends — metric chips, trend chart with normal-range band, and
/// the latest value of every tracked metric.
class LabsPage extends ConsumerStatefulWidget {
  const LabsPage({super.key, this.initialMetricCode});

  final String? initialMetricCode;

  @override
  ConsumerState<LabsPage> createState() => _LabsPageState();
}

class _LabsPageState extends ConsumerState<LabsPage> {
  @override
  void initState() {
    super.initState();
    _applyInitialMetric();
  }

  @override
  void didUpdateWidget(covariant LabsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMetricCode != widget.initialMetricCode) {
      _applyInitialMetric();
    }
  }

  void _applyInitialMetric() {
    final code = widget.initialMetricCode;
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(selectedMetricProvider.notifier).selectByCode(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final selected = ref.watch(selectedMetricProvider);
    final seriesAsync = ref.watch(labSeriesProvider);

    return Scaffold(
      backgroundColor: colors.bgSection,
      body: SafeArea(
        bottom: false,
        child: seriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => EmptyState(
            icon: Icons.science_outlined,
            title: l10n.labsUnavailableTitle,
            message: l10n.labsUnavailableMessage,
          ),
          data: (allSeries) {
            if (allSeries.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmptyState(
                    icon: Icons.science_outlined,
                    title: l10n.noLabsTitle,
                    message: l10n.noLabsMessage,
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed('labEntry'),
                    child: Text(
                      l10n.enterValuesManually,
                      style: typo.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              );
            }
            final current = allSeries
                    .firstWhereOrNull((s) => s.metric == selected) ??
                allSeries.first;
            final lastTest = allSeries
                .map((s) => s.latest?.takenAt)
                .whereType<DateTime>()
                .reduce((a, b) => a.isAfter(b) ? a : b);

            return ListView(
              padding: const EdgeInsets.only(bottom: AppShell.navClearance),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.labs,
                          style: typo.pageTitle.copyWith(fontSize: 25),
                        ),
                      ),
                      Text(
                        l10n.lastTest(lastTest.monthDay),
                        style:
                            typo.bodySmall.copyWith(color: colors.muted),
                      ),
                      const SizedBox(width: 10),
                      const _AddValuesButton(),
                    ],
                  ),
                ),
                MetricChipRow(
                  metrics: [
                    for (final metric in chartableMetrics)
                      if (allSeries.any((s) => s.metric == metric)) metric,
                  ],
                  selected: current.metric,
                  onSelect: (metric) => ref
                      .read(selectedMetricProvider.notifier)
                      .select(metric),
                ),
                const SizedBox(height: 12),
                LabChartCard(series: current),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
                  child: Text(
                    l10n.allValuesOn(lastTest.monthDay),
                    style: typo.sectionTitle.copyWith(fontSize: 15),
                  ),
                ),
                AllValuesCard(
                  series: allSeries,
                  onRowTap: (series) {
                    if (chartableMetrics.contains(series.metric)) {
                      ref
                          .read(selectedMetricProvider.notifier)
                          .select(series.metric);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Small accent pill opening the manual value entry form.
class _AddValuesButton extends StatelessWidget {
  const _AddValuesButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.enterLabValuesManually,
      child: Material(
        color: colors.accentSoft,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: () => context.pushNamed('labEntry'),
          customBorder: const StadiumBorder(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
