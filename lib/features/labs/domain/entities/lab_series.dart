import '../../../../shared/domain/lab_metric.dart';

/// One stored observation, addressable for editing and deletion.
class LabReading {
  const LabReading({
    required this.id,
    required this.takenAt,
    required this.value,
  });

  final String id;
  final DateTime takenAt;
  final double value;
}

/// One observation in a metric's history.
class LabPoint {
  const LabPoint({required this.takenAt, required this.value});

  final DateTime takenAt;
  final double value;
}

/// How the latest value of a series relates to its normal range.
enum LabRangeStatus { belowRange, aboveRange, steady }

/// A metric's full history plus derived display state.
class LabSeries {
  const LabSeries({
    required this.metric,
    required this.points,
    this.normalMinOverride,
    this.normalMaxOverride,
  });

  final LabMetric metric;

  /// Oldest first.
  final List<LabPoint> points;

  /// Patient-specific range overrides — e.g. the weight band derives from
  /// the patient's dry weight, not a population constant.
  final double? normalMinOverride;
  final double? normalMaxOverride;

  double get normalMin => normalMinOverride ?? metric.normalMin;

  double get normalMax => normalMaxOverride ?? metric.normalMax;

  LabPoint? get latest => points.isEmpty ? null : points.last;

  bool get latestAbnormal {
    final point = latest;
    return point != null &&
        (point.value < normalMin || point.value > normalMax);
  }

  LabRangeStatus get status {
    final point = latest;
    if (point == null) return LabRangeStatus.steady;
    if (point.value < normalMin) return LabRangeStatus.belowRange;
    if (point.value > normalMax) return LabRangeStatus.aboveRange;
    return LabRangeStatus.steady;
  }

  String get statusLabel => switch (status) {
        LabRangeStatus.belowRange => 'below range',
        LabRangeStatus.aboveRange => 'above range',
        LabRangeStatus.steady => 'steady',
      };

  /// "↓" / "↑" marker next to the unit; empty when in range.
  String get directionArrow => switch (status) {
        LabRangeStatus.belowRange => ' ↓',
        LabRangeStatus.aboveRange => ' ↑',
        LabRangeStatus.steady => '',
      };

  String get rangeCaption =>
      '${metric.label} · normal ${metric.format(normalMin)}–'
      '${metric.format(normalMax)} · shaded = normal';
}
