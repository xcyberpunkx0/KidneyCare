import '../../../../core/widgets/metric_tile.dart' show MetricTrend;
import '../../../../shared/domain/lab_metric.dart';

/// Which summary tile a [VitalReading] represents. Presentation owns the
/// localized label for each kind.
enum VitalKind { dryWeight, hemoglobin, potassium, bloodPressure, albumin, activeMeds }

/// One summary tile on the home vitals grid.
class VitalReading {
  const VitalReading({
    required this.kind,
    required this.value,
    this.abnormal = false,
    this.trend,
    this.deltaNote,
    this.metricCode,
  });

  final VitalKind kind;
  final String value;
  final bool abnormal;
  final MetricTrend? trend;
  final String? deltaNote;

  /// Metric to open on the labs screen when tapped, if chartable.
  final String? metricCode;
}

/// Why a value needs attention. Presentation owns the localized wording.
enum AttentionReason { belowRangeRecheck, fallingStreak, aboveRangeDiet }

/// One row on the "Needs attention" card.
class AttentionItem {
  const AttentionItem({
    required this.metric,
    required this.value,
    required this.reason,
    this.fallingMonths = 0,
    this.metricCode,
  });

  final LabMetric metric;
  final double value;
  final AttentionReason reason;

  /// Consecutive falling months, when [reason] is
  /// [AttentionReason.fallingStreak].
  final int fallingMonths;

  final String? metricCode;

  /// Compact value marker, e.g. "Hb 9.4↓" — symbols and numbers only, so
  /// it needs no translation.
  String get shortValue {
    final symbol = switch (metric) {
      LabMetric.hemoglobin => 'Hb',
      LabMetric.potassium => 'K⁺',
      _ => metric.label,
    };
    final arrow = value < metric.normalMin ? '↓' : '↑';
    return '$symbol ${metric.format(value)}$arrow';
  }
}
