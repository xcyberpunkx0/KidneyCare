import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/lab_metric.dart';

/// Metrics offered as chart chips, in display order.
const chartableMetrics = [
  LabMetric.hemoglobin,
  LabMetric.potassium,
  LabMetric.creatinine,
  LabMetric.urea,
  LabMetric.sodium,
  LabMetric.albumin,
  LabMetric.phosphorus,
  LabMetric.calcium,
  LabMetric.whiteBloodCells,
  LabMetric.platelets,
  LabMetric.weight,
];

/// Currently charted metric.
class SelectedMetricController extends Notifier<LabMetric> {
  @override
  LabMetric build() => LabMetric.hemoglobin;

  void select(LabMetric metric) => state = metric;

  void selectByCode(String code) {
    final metric = LabMetric.fromCode(code);
    if (metric != null && chartableMetrics.contains(metric)) {
      state = metric;
    }
  }
}

final selectedMetricProvider =
    NotifierProvider<SelectedMetricController, LabMetric>(
  SelectedMetricController.new,
);
