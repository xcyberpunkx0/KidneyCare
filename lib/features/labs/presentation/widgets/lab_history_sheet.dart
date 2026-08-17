import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../shared/domain/lab_metric.dart';
import '../../data/repository_impl/labs_repository_impl.dart';
import '../../domain/entities/lab_series.dart';

final labReadingsProvider =
    StreamProvider.autoDispose.family<List<LabReading>, LabMetric>(
  (ref, metric) => ref.watch(labsRepositoryProvider).watchReadings(metric),
);

/// Opens the reading history for [series]' metric: every stored value with
/// its date, each one editable or deletable — the fix for a mistyped entry.
Future<void> showLabHistorySheet(BuildContext context, LabSeries series) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.bgSection,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => LabHistorySheet(series: series),
  );
}

class LabHistorySheet extends ConsumerWidget {
  const LabHistorySheet({super.key, required this.series});

  final LabSeries series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typo;
    final l10n = context.l10n;
    final metric = series.metric;
    final readings = ref.watch(labReadingsProvider(metric)).value;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
            child: Text(
              l10n.labHistoryTitle(metric.label),
              style: typo.sectionTitle.copyWith(fontSize: 15),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              children: [
                if (readings != null)
                  for (var i = 0; i < readings.length; i++)
                    _ReadingRow(
                      series: series,
                      reading: readings[i],
                      isLast: i == readings.length - 1,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingRow extends ConsumerWidget {
  const _ReadingRow({
    required this.series,
    required this.reading,
    required this.isLast,
  });

  final LabSeries series;
  final LabReading reading;
  final bool isLast;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final newValue = await showDialog<double>(
      context: context,
      builder: (_) => _EditReadingDialog(
        metric: series.metric,
        reading: reading,
      ),
    );
    if (newValue == null) return;
    await ref
        .read(labsRepositoryProvider)
        .updateReading(reading.id, newValue);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteReadingConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteReading),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(labsRepositoryProvider).deleteReading(reading.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final metric = series.metric;
    final abnormal = reading.value < series.normalMin ||
        reading.value > series.normalMax;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              reading.takenAt.monthDayYear,
              style: typo.cardTitle.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${metric.format(reading.value)} ${metric.unit}',
            style: typo.number(13.5,
                weight: FontWeight.w600,
                color: abnormal ? colors.amber : colors.ink),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: l10n.editReadingOn(reading.takenAt.monthDayYear),
            icon: Icon(Icons.edit_outlined, size: 19, color: colors.muted),
            onPressed: () => _edit(context, ref),
          ),
          IconButton(
            tooltip: l10n.deleteReading,
            icon: Icon(Icons.delete_outline, size: 19, color: colors.muted),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Value-correction dialog; WBC and platelets keep their report-unit toggle
/// so the corrected number can be typed straight off the paper.
class _EditReadingDialog extends StatefulWidget {
  const _EditReadingDialog({required this.metric, required this.reading});

  final LabMetric metric;
  final LabReading reading;

  @override
  State<_EditReadingDialog> createState() => _EditReadingDialogState();
}

class _EditReadingDialogState extends State<_EditReadingDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.metric.format(widget.reading.value),
  );
  var _inAltUnit = false;
  var _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleUnit() {
    final metric = widget.metric;
    final typed = double.tryParse(_controller.text.trim());
    setState(() {
      _inAltUnit = !_inAltUnit;
      if (typed == null) return;
      // Convert the number in place so the field always matches its unit.
      _controller.text = _inAltUnit
          ? metric.formatAsAlt(typed)
          : metric.format(typed * metric.altUnitFactor!);
    });
  }

  void _save() {
    final typed = double.tryParse(_controller.text.trim());
    if (typed == null) {
      setState(() => _invalid = true);
      return;
    }
    final canonical =
        _inAltUnit ? typed * widget.metric.altUnitFactor! : typed;
    Navigator.pop(context, canonical);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final metric = widget.metric;
    final unit = _inAltUnit ? metric.altUnit! : metric.unit;

    return AlertDialog(
      title: Text(l10n.editReading, style: typo.cardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${metric.label} · ${widget.reading.takenAt.monthDayYear}',
            style: typo.caption.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style:
                typo.number(15, weight: FontWeight.w600, color: colors.ink),
            cursorColor: colors.accent,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              isDense: true,
              errorText: _invalid ? l10n.invalidNumber : null,
              suffixIcon: metric.altUnit == null
                  ? null
                  : Semantics(
                      button: true,
                      label: l10n.changeUnit(unit),
                      child: InkWell(
                        onTap: _toggleUnit,
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
              suffixIconConstraints: const BoxConstraints(),
              suffixText: metric.altUnit == null ? metric.unit : null,
              suffixStyle:
                  typo.caption.copyWith(fontSize: 10.5, color: colors.muted),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
