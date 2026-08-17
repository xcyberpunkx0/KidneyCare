import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/lab_series.dart';

/// The trend chart card: big current value, range status, and a line chart
/// with the normal range shaded behind it.
class LabChartCard extends StatelessWidget {
  const LabChartCard({super.key, required this.series, this.onHistoryTap});

  final LabSeries series;

  /// Opens the reading history for corrections.
  final VoidCallback? onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final metric = series.metric;
    final latest = series.latest;
    final abnormal = series.latestAbnormal;
    final valueColor = abnormal ? colors.amber : colors.ink;
    final statusLabel = switch (series.status) {
      LabRangeStatus.belowRange => l10n.belowRange,
      LabRangeStatus.aboveRange => l10n.aboveRange,
      LabRangeStatus.steady => l10n.steady,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: colors.cardTranslucent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: latest == null ? '—' : metric.format(latest.value),
                    children: [
                      TextSpan(
                        text: ' ${metric.unit}${series.directionArrow}',
                        style: typo.bodySmall.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: abnormal
                              ? colors.amber.withValues(alpha: 0.7)
                              : colors.muted,
                        ),
                      ),
                    ],
                  ),
                  style: typo
                      .number(32, color: valueColor)
                      .copyWith(letterSpacing: -1),
                ),
              ),
              StatusChip(
                label: statusLabel,
                tone: abnormal ? StatusTone.amber : StatusTone.neutral,
              ),
              if (onHistoryTap != null) ...[
                const SizedBox(width: 4),
                Semantics(
                  button: true,
                  label: l10n.viewReadingHistory(metric.label),
                  child: InkWell(
                    onTap: onHistoryTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child:
                          Icon(Icons.history, size: 18, color: colors.muted),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.rangeCaption(
              metric.label,
              metric.format(series.normalMin),
              metric.format(series.normalMax),
            ),
            style: typo.caption.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: RepaintBoundary(child: _chart(colors, typo, l10n)),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _chart(
    AppColors colors,
    AppTypography typo,
    AppLocalizations l10n,
  ) {
    final points = series.points;
    if (points.isEmpty) {
      return Center(
        child: Text(
          l10n.noReadingsYet,
          style: typo.caption.copyWith(color: colors.muted),
        ),
      );
    }

    final metric = series.metric;
    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final values = points.map((p) => p.value);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minY = (minValue < series.normalMin ? minValue : series.normalMin);
    final maxY = (maxValue > series.normalMax ? maxValue : series.normalMax);
    final padding = (maxY - minY) * 0.25 + 0.1;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        minX: -0.3,
        maxX: (points.length - 1) + 0.3,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: series.normalMin,
              y2: series.normalMax,
              color: colors.band,
            ),
          ],
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 ||
                    index >= points.length ||
                    (value - index).abs() > 0.01) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    DateFormat('MMM')
                        .format(points[index].takenAt)
                        .toUpperCase(),
                    style: typo.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: colors.muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => colors.chipActive,
            getTooltipItems: (touchedSpots) => [
              for (final spot in touchedSpots)
                LineTooltipItem(
                  '${metric.format(spot.y)} ${metric.unit}\n'
                  '${DateFormat('MMM d').format(points[spot.x.round()].takenAt)}',
                  typo.caption.copyWith(
                    color: colors.onChipActive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: colors.chartLine,
            barWidth: 2.5,
            isCurved: false,
            dotData: FlDotData(
              getDotPainter: (spot, percent, bar, index) {
                final isLast = index == points.length - 1;
                final lastAbnormal = isLast && series.latestAbnormal;
                if (lastAbnormal) {
                  return FlDotCirclePainter(
                    radius: 5.5,
                    color: colors.amberDot,
                    strokeWidth: 1.5,
                    strokeColor: colors.amberDot.withValues(alpha: 0.4),
                  );
                }
                return FlDotCirclePainter(
                  radius: isLast ? 4.5 : 3.5,
                  color: colors.chartLine,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                );
              },
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
