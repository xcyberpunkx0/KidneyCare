import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/lab_series.dart';

/// "All values" card: the latest reading of every tracked metric, abnormal
/// ones in amber with a direction arrow.
class AllValuesCard extends StatelessWidget {
  const AllValuesCard({
    super.key,
    required this.series,
    this.onRowTap,
    this.onRowLongPress,
  });

  final List<LabSeries> series;
  final void Function(LabSeries series)? onRowTap;

  /// Long-press opens the reading history for corrections.
  final void Function(LabSeries series)? onRowLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final withData = series.where((s) => s.latest != null).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.cardTranslucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < withData.length; i++)
            _ValueRow(
              series: withData[i],
              isLast: i == withData.length - 1,
              onTap:
                  onRowTap == null ? null : () => onRowTap!(withData[i]),
              onLongPress: onRowLongPress == null
                  ? null
                  : () => onRowLongPress!(withData[i]),
            ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.series,
    required this.isLast,
    this.onTap,
    this.onLongPress,
  });

  final LabSeries series;
  final bool isLast;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final abnormal = series.latestAbnormal;
    final latest = series.latest!;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: colors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              series.metric.label,
              style: typo.cardTitle.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '${series.metric.format(latest.value)}'
              '${series.directionArrow}',
              style: typo
                  .number(13.5,
                      weight: FontWeight.w600,
                      color: abnormal ? colors.amber : colors.ink)
                  .copyWith(),
            ),
          ],
        ),
      ),
    );
  }
}
