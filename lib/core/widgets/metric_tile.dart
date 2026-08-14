import 'package:flutter/material.dart';

import '../l10n/l10n_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

/// Direction of a metric's recent movement.
enum MetricTrend { up, down, flat }

/// Compact vitals tile for the home summary grid.
///
/// Normal values sit on a plain card; abnormal values shift the whole tile
/// to the amber treatment — background, border and text — so trouble is
/// visible before reading a single number.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.abnormal = false,
    this.trend,
    this.deltaNote,
  });

  final String label;
  final String value;
  final bool abnormal;
  final MetricTrend? trend;

  /// Small green annotation after the value, e.g. "+0.1".
  final String? deltaNote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final valueColor = abnormal ? colors.amber : colors.ink;

    return Semantics(
      label: abnormal
          ? context.l10n.abnormalSemantics(label, value)
          : '$label $value',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: abnormal ? colors.amberBg : colors.card,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: abnormal ? colors.amberBorder : colors.cardBorder,
          ),
          boxShadow: colors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.metricLabel.copyWith(
                color: abnormal
                    ? colors.amber.withValues(alpha: 0.8)
                    : colors.muted,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text.rich(
              TextSpan(
                text: value,
                children: [
                  if (trend == MetricTrend.down) const TextSpan(text: ' ↓'),
                  if (trend == MetricTrend.up) const TextSpan(text: ' ↑'),
                  if (deltaNote != null)
                    TextSpan(
                      text: ' $deltaNote',
                      style: typo.caption.copyWith(
                        fontSize: 10,
                        color: colors.green,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              style: typo.metricValue.copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
