/// Tracked laboratory metrics with their units and normal ranges.
///
/// Ranges are the dialysis-adjusted targets shown on charts as the shaded
/// normal band. A value outside the band is flagged abnormal (amber).
enum LabMetric {
  hemoglobin('hb', 'Hemoglobin', 'g/dL', 10, 12, 1),
  potassium('k', 'Potassium', 'mmol/L', 3.5, 5.0, 1),
  creatinine('cr', 'Creatinine', 'mg/dL', 2.0, 10.0, 1),
  urea('urea', 'Urea', 'mg/dL', 15, 50, 0),
  sodium('na', 'Sodium', 'mmol/L', 135, 145, 0),
  albumin('alb', 'Albumin', 'g/dL', 3.5, 5.0, 1),
  phosphorus('phos', 'Phosphorus', 'mg/dL', 3.0, 5.5, 1),
  calcium('ca', 'Calcium', 'mg/dL', 8.4, 10.2, 1),
  whiteBloodCells('wbc', 'WBC', '10³/µL', 4.0, 11.0, 1),
  platelets('plt', 'Platelets', '10³/µL', 150, 450, 0),
  weight('wt', 'Weight', 'kg', 56.5, 58.5, 1),
  bloodPressureSystolic('bps', 'BP systolic', 'mmHg', 110, 140, 0),
  bloodPressureDiastolic('bpd', 'BP diastolic', 'mmHg', 70, 90, 0);

  const LabMetric(
    this.code,
    this.label,
    this.unit,
    this.normalMin,
    this.normalMax,
    this.decimals,
  );

  final String code;
  final String label;
  final String unit;
  final double normalMin;
  final double normalMax;
  final int decimals;

  static LabMetric? fromCode(String code) {
    for (final metric in values) {
      if (metric.code == code) return metric;
    }
    return null;
  }

  bool isAbnormal(double value) => value < normalMin || value > normalMax;

  bool isBelow(double value) => value < normalMin;

  String format(double value) => value.toStringAsFixed(decimals);
}
