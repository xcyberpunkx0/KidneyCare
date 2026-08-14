import '../../../../core/storage/app_database.dart';
import '../../../../core/widgets/metric_tile.dart' show MetricTrend;
import '../../../../shared/domain/lab_metric.dart';
import '../entities/vital_reading.dart';

/// Everything the top of the home screen needs, derived from raw history.
class VitalsSnapshot {
  const VitalsSnapshot({required this.tiles, required this.attention});

  final List<VitalReading> tiles;
  final List<AttentionItem> attention;
}

/// Derives the vitals grid and attention items from lab history.
///
/// Pure function of its inputs so it is trivially unit-testable. Emits
/// only data — the localized wording belongs to presentation.
VitalsSnapshot buildVitalsSnapshot({
  required Patient? patient,
  required List<LabResult> allLabs,
  required int activeMedCount,
}) {
  final byMetric = <String, List<LabResult>>{};
  for (final lab in allLabs) {
    byMetric.putIfAbsent(lab.metricCode, () => []).add(lab);
  }

  double? latest(String code) => byMetric[code]?.lastOrNull?.value;

  MetricTrend? trend(String code) {
    final series = byMetric[code];
    if (series == null || series.length < 2) return null;
    final last = series[series.length - 1].value;
    final previous = series[series.length - 2].value;
    if (last > previous) return MetricTrend.up;
    if (last < previous) return MetricTrend.down;
    return MetricTrend.flat;
  }

  bool abnormal(LabMetric metric) {
    final value = latest(metric.code);
    return value != null && metric.isAbnormal(value);
  }

  /// Consecutive month-over-month declines ending at the latest value.
  int fallingStreak(String code) {
    final series = byMetric[code];
    if (series == null) return 0;
    var streak = 0;
    for (var i = series.length - 1; i > 0; i--) {
      if (series[i].value < series[i - 1].value) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  final hb = latest(LabMetric.hemoglobin.code);
  final k = latest(LabMetric.potassium.code);
  final alb = latest(LabMetric.albumin.code);
  final bps = latest(LabMetric.bloodPressureSystolic.code);
  final bpd = latest(LabMetric.bloodPressureDiastolic.code);

  final tiles = <VitalReading>[
    VitalReading(
      kind: VitalKind.dryWeight,
      value: patient == null ? '—' : patient.dryWeightKg.toStringAsFixed(1),
      deltaNote: patient != null && patient.dryWeightDeltaKg != 0
          ? '${patient.dryWeightDeltaKg > 0 ? '+' : ''}'
              '${patient.dryWeightDeltaKg.toStringAsFixed(1)}'
          : null,
      metricCode: LabMetric.weight.code,
    ),
    VitalReading(
      kind: VitalKind.hemoglobin,
      value: hb == null ? '—' : LabMetric.hemoglobin.format(hb),
      abnormal: abnormal(LabMetric.hemoglobin),
      trend: trend(LabMetric.hemoglobin.code),
      metricCode: LabMetric.hemoglobin.code,
    ),
    VitalReading(
      kind: VitalKind.potassium,
      value: k == null ? '—' : LabMetric.potassium.format(k),
      abnormal: abnormal(LabMetric.potassium),
      trend: trend(LabMetric.potassium.code),
      metricCode: LabMetric.potassium.code,
    ),
    VitalReading(
      kind: VitalKind.bloodPressure,
      value: bps == null || bpd == null
          ? '—'
          : '${bps.round()}/${bpd.round()}',
      abnormal: bps != null &&
          LabMetric.bloodPressureSystolic.isAbnormal(bps),
    ),
    VitalReading(
      kind: VitalKind.albumin,
      value: alb == null ? '—' : LabMetric.albumin.format(alb),
      abnormal: abnormal(LabMetric.albumin),
      metricCode: LabMetric.albumin.code,
    ),
    VitalReading(kind: VitalKind.activeMeds, value: '$activeMedCount'),
  ];

  final attention = <AttentionItem>[];
  if (hb != null && LabMetric.hemoglobin.isBelow(hb)) {
    final streak = fallingStreak(LabMetric.hemoglobin.code);
    attention.add(AttentionItem(
      metric: LabMetric.hemoglobin,
      value: hb,
      reason: streak >= 2
          ? AttentionReason.fallingStreak
          : AttentionReason.belowRangeRecheck,
      fallingMonths: streak,
      metricCode: LabMetric.hemoglobin.code,
    ));
  }
  if (k != null && k > LabMetric.potassium.normalMax) {
    attention.add(AttentionItem(
      metric: LabMetric.potassium,
      value: k,
      reason: AttentionReason.aboveRangeDiet,
      metricCode: LabMetric.potassium.code,
    ));
  }
  return VitalsSnapshot(tiles: tiles, attention: attention);
}
