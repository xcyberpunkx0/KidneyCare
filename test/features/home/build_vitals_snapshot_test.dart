import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/widgets/metric_tile.dart';
import 'package:recora/features/home/domain/entities/vital_reading.dart';
import 'package:recora/features/home/domain/usecases/build_vitals_snapshot.dart';

LabResult _lab(String code, double value, int monthsAgo) {
  return LabResult(
    id: '$code-$monthsAgo',
    metricCode: code,
    value: value,
    takenAt: DateTime(2026, 8 - monthsAgo, 2),
  );
}

const _patient = Patient(
  id: 'p1',
  name: 'N. Ramachandran',
  initials: 'NR',
  age: 63,
  conditionSummary: 'CKD-5',
  scheduleJson: '{}',
  bloodGroup: '',
  allergies: '',
  emergencyContact: '',
  comorbidities: '',
  dialysisCenter: 'Nephron Centre',
  dryWeightKg: 57.5,
  dryWeightDeltaKg: 0.1,
);

void main() {
  group('buildVitalsSnapshot', () {
    test('flags a falling below-range hemoglobin with streak length', () {
      final snapshot = buildVitalsSnapshot(
        patient: _patient,
        allLabs: [
          _lab('hb', 10.4, 3),
          _lab('hb', 10.1, 2),
          _lab('hb', 9.8, 1),
          _lab('hb', 9.4, 0),
        ],
        activeMedCount: 9,
      );

      expect(snapshot.attention, hasLength(1));
      expect(snapshot.attention.first.shortValue, 'Hb 9.4↓');
      expect(
        snapshot.attention.first.reason,
        AttentionReason.fallingStreak,
      );
      expect(snapshot.attention.first.fallingMonths, 3);

      final hbTile = snapshot.tiles
          .firstWhere((t) => t.kind == VitalKind.hemoglobin);
      expect(hbTile.abnormal, isTrue);
      expect(hbTile.trend, MetricTrend.down);
    });

    test('flags elevated potassium', () {
      final snapshot = buildVitalsSnapshot(
        patient: _patient,
        allLabs: [_lab('k', 4.9, 1), _lab('k', 5.3, 0)],
        activeMedCount: 0,
      );
      expect(
        snapshot.attention.map((a) => a.shortValue),
        contains('K⁺ 5.3↑'),
      );
      expect(
        snapshot.attention.map((a) => a.reason),
        contains(AttentionReason.aboveRangeDiet),
      );
    });

    test('in-range values produce no attention items', () {
      final snapshot = buildVitalsSnapshot(
        patient: _patient,
        allLabs: [_lab('hb', 11.0, 0), _lab('k', 4.4, 0)],
        activeMedCount: 5,
      );
      expect(snapshot.attention, isEmpty);
    });

    test('missing data renders placeholders instead of crashing', () {
      final snapshot = buildVitalsSnapshot(
        patient: null,
        allLabs: const [],
        activeMedCount: 0,
      );
      expect(snapshot.tiles.first.value, '—');
      expect(snapshot.attention, isEmpty);
    });

    test('combines blood pressure into one reading', () {
      final snapshot = buildVitalsSnapshot(
        patient: _patient,
        allLabs: [_lab('bps', 138, 0), _lab('bpd', 86, 0)],
        activeMedCount: 0,
      );
      final bp = snapshot.tiles
          .firstWhere((t) => t.kind == VitalKind.bloodPressure);
      expect(bp.value, '138/86');
    });
  });
}
