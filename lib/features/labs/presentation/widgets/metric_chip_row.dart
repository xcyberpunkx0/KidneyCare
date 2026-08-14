import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/lab_metric.dart';

/// Horizontally scrolling row of metric selector chips.
class MetricChipRow extends StatelessWidget {
  const MetricChipRow({
    super.key,
    required this.metrics,
    required this.selected,
    required this.onSelect,
  });

  final List<LabMetric> metrics;
  final LabMetric selected;
  final ValueChanged<LabMetric> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: metrics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          final isSelected = metric == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: l10n.showMetricChart(metric.label),
            child: Material(
              color: isSelected ? colors.chipActive : colors.cardTranslucent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                side: isSelected
                    ? BorderSide.none
                    : BorderSide(color: colors.cardBorder),
              ),
              child: InkWell(
                onTap: () => onSelect(metric),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Center(
                    child: Text(
                      metric.label,
                      style: typo.bodySmall.copyWith(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected ? colors.onChipActive : colors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
