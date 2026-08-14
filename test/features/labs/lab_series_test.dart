import 'package:flutter_test/flutter_test.dart';
import 'package:recora/features/labs/domain/entities/lab_series.dart';
import 'package:recora/shared/domain/lab_metric.dart';

LabSeries _series(LabMetric metric, List<double> values) {
  return LabSeries(
    metric: metric,
    points: [
      for (var i = 0; i < values.length; i++)
        LabPoint(takenAt: DateTime(2026, i + 1, 2), value: values[i]),
    ],
  );
}

void main() {
  group('LabSeries', () {
    test('below range status and arrow', () {
      final series = _series(LabMetric.hemoglobin, [10.5, 9.4]);
      expect(series.status, LabRangeStatus.belowRange);
      expect(series.statusLabel, 'below range');
      expect(series.directionArrow, ' ↓');
      expect(series.latestAbnormal, isTrue);
    });

    test('above range status', () {
      final series = _series(LabMetric.potassium, [4.4, 5.3]);
      expect(series.status, LabRangeStatus.aboveRange);
      expect(series.statusLabel, 'above range');
    });

    test('steady when inside the band', () {
      final series = _series(LabMetric.albumin, [3.6, 3.8]);
      expect(series.status, LabRangeStatus.steady);
      expect(series.directionArrow, isEmpty);
      expect(series.latestAbnormal, isFalse);
    });

    test('empty series stays steady with no latest', () {
      const series = LabSeries(
        metric: LabMetric.creatinine,
        points: [],
      );
      expect(series.latest, isNull);
      expect(series.status, LabRangeStatus.steady);
    });

    test('range caption spells out the shaded band', () {
      final series = _series(LabMetric.hemoglobin, [9.4]);
      expect(series.rangeCaption, contains('normal 10.0–12.0'));
      expect(series.rangeCaption, contains('shaded = normal'));
    });
  });
}
