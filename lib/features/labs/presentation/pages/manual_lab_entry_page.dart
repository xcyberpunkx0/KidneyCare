import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../shared/domain/lab_metric.dart';
import '../controllers/manual_entry_controller.dart';

/// Manual lab entry — for reports that were phoned in, read out at the
/// centre, or otherwise never photographed. Blank fields are simply
/// skipped.
class ManualLabEntryPage extends ConsumerStatefulWidget {
  const ManualLabEntryPage({super.key});

  @override
  ConsumerState<ManualLabEntryPage> createState() =>
      _ManualLabEntryPageState();
}

/// Metric groups on the entry form; each resolves its title via l10n.
enum _MetricGroup {
  kidneyFunction([
    LabMetric.creatinine,
    LabMetric.urea,
    LabMetric.potassium,
    LabMetric.sodium,
    LabMetric.calcium,
    LabMetric.phosphorus,
    LabMetric.albumin,
  ]),
  bloodCounts([
    LabMetric.hemoglobin,
    LabMetric.whiteBloodCells,
    LabMetric.platelets,
  ]),
  vitals([
    LabMetric.weight,
    LabMetric.bloodPressureSystolic,
    LabMetric.bloodPressureDiastolic,
  ]);

  const _MetricGroup(this.metrics);

  final List<LabMetric> metrics;

  String localizedTitle(AppLocalizations l10n) => switch (this) {
        _MetricGroup.kidneyFunction => l10n.kidneyFunction,
        _MetricGroup.bloodCounts => l10n.bloodCounts,
        _MetricGroup.vitals => l10n.vitalsGroup,
      };
}

class _ManualLabEntryPageState extends ConsumerState<ManualLabEntryPage> {

  final Map<LabMetric, TextEditingController> _controllers = {
    for (final group in _MetricGroup.values)
      for (final metric in group.metrics) metric: TextEditingController(),
  };
  DateTime _takenAt = DateTime.now();

  /// Metrics currently being typed in their report unit (e.g. cells/cumm)
  /// instead of the canonical unit.
  final Set<LabMetric> _altUnits = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _takenAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: context.l10n.reportDateDialogTitle,
    );
    if (picked != null) setState(() => _takenAt = picked);
  }

  Future<void> _save() async {
    final values = ManualEntryController.parseValues(
      {
        for (final MapEntry(key: metric, value: controller)
            in _controllers.entries)
          metric: controller.text,
      },
      inAltUnit: _altUnits,
    );
    if (values == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.invalidNumber),
      ));
      return;
    }
    final saved = await ref
        .read(manualEntryProvider.notifier)
        .save(takenAt: _takenAt, values: values);
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.labValuesSaved),
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final state = ref.watch(manualEntryProvider);

    ref.listen(manualEntryProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
        ref.read(manualEntryProvider.notifier).dismissFailure();
      }
    });

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Text(l10n.enterLabValues,
                style: typo.pageTitle.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              l10n.enterLabValuesCopy,
              style: typo.body.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(l10n.reportDate,
                    style: typo.overline.copyWith(
                        fontSize: 10.5, color: colors.muted)),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: l10n.changeReportDate(_takenAt.monthDayYear),
                  child: Material(
                    color: colors.fieldBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: colors.fieldBorder, width: 1.5),
                    ),
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _takenAt.monthDayYear,
                              style: typo.number(13.5,
                                  weight: FontWeight.w600,
                                  color: colors.ink),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.event_outlined,
                                size: 14, color: colors.muted),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final group in _MetricGroup.values) ...[
              const SizedBox(height: 10),
              _MetricGroupCard(
                title: group.localizedTitle(l10n),
                metrics: group.metrics,
                controllers: _controllers,
                altUnits: _altUnits,
                onToggleUnit: (metric) => setState(() {
                  _altUnits.contains(metric)
                      ? _altUnits.remove(metric)
                      : _altUnits.add(metric);
                }),
              ),
            ],
            const SizedBox(height: 18),
            Material(
              color: colors.accent,
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                onTap: state.saving ? null : _save,
                borderRadius: BorderRadius.circular(99),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      state.saving ? l10n.saving : l10n.saveToTimeline,
                      style: typo.cardTitle
                          .copyWith(fontSize: 15, color: colors.onAccent),
                    ),
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

class _MetricGroupCard extends StatelessWidget {
  const _MetricGroupCard({
    required this.title,
    required this.metrics,
    required this.controllers,
    required this.altUnits,
    required this.onToggleUnit,
  });

  final String title;
  final List<LabMetric> metrics;
  final Map<LabMetric, TextEditingController> controllers;
  final Set<LabMetric> altUnits;
  final ValueChanged<LabMetric> onToggleUnit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardTranslucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typo.overline
                .copyWith(fontSize: 10.5, color: colors.muted),
          ),
          for (var i = 0; i < metrics.length; i++) ...[
            const SizedBox(height: 8),
            _MetricRow(
                metric: metrics[i],
                controller: controllers[metrics[i]]!,
                inAltUnit: altUnits.contains(metrics[i]),
                onToggleUnit: onToggleUnit),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.metric,
    required this.controller,
    required this.inAltUnit,
    required this.onToggleUnit,
  });

  final LabMetric metric;
  final TextEditingController controller;
  final bool inAltUnit;
  final ValueChanged<LabMetric> onToggleUnit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final unit = inAltUnit ? metric.altUnit! : metric.unit;
    final rangeMin = inAltUnit
        ? metric.formatAsAlt(metric.normalMin)
        : metric.format(metric.normalMin);
    final rangeMax = inAltUnit
        ? metric.formatAsAlt(metric.normalMax)
        : metric.format(metric.normalMax);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.label,
                  style: typo.cardTitle
                      .copyWith(fontWeight: FontWeight.w500)),
              Text(
                context.l10n.normalRangeHint(rangeMin, rangeMax, unit),
                style: typo.caption
                    .copyWith(fontSize: 10.5, color: colors.muted),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 132,
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            style: typo.number(14,
                weight: FontWeight.w600, color: colors.ink),
            cursorColor: colors.accent,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: colors.fieldBg,
              suffixIcon: metric.altUnit == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Semantics(
                        button: true,
                        label: context.l10n.changeUnit(unit),
                        child: InkWell(
                          onTap: () => onToggleUnit(metric),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(unit,
                                    style: typo.caption.copyWith(
                                        fontSize: 10.5,
                                        color: colors.accent,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 2),
                                Icon(Icons.swap_horiz,
                                    size: 13, color: colors.accent),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              suffixIconConstraints: const BoxConstraints(),
              suffixText: metric.altUnit == null ? metric.unit : null,
              suffixStyle: typo.caption
                  .copyWith(fontSize: 10.5, color: colors.muted),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: colors.fieldBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: colors.accent, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
