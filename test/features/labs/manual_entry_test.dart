import 'package:flutter_test/flutter_test.dart';
import 'package:recora/features/labs/presentation/controllers/manual_entry_controller.dart';
import 'package:recora/shared/domain/lab_metric.dart';

void main() {
  group('ManualEntryController.parseValues', () {
    test('parses filled fields and skips blanks', () {
      final values = ManualEntryController.parseValues({
        LabMetric.hemoglobin: '9.4',
        LabMetric.creatinine: ' 8.2 ',
        LabMetric.urea: '',
        LabMetric.sodium: '   ',
      });
      expect(values, {
        LabMetric.hemoglobin: 9.4,
        LabMetric.creatinine: 8.2,
      });
    });

    test('rejects non-numeric input', () {
      final values = ManualEntryController.parseValues({
        LabMetric.hemoglobin: 'nine',
      });
      expect(values, isNull);
    });

    test('all-blank input parses to an empty map', () {
      final values = ManualEntryController.parseValues({
        LabMetric.hemoglobin: '',
        LabMetric.potassium: '',
      });
      expect(values, isEmpty);
    });

    test('converts report units into canonical units when selected', () {
      final values = ManualEntryController.parseValues(
        {
          LabMetric.whiteBloodCells: '3200',
          LabMetric.platelets: '1.80',
          LabMetric.hemoglobin: '8.7',
        },
        inAltUnit: {LabMetric.whiteBloodCells, LabMetric.platelets},
      );
      expect(values, {
        LabMetric.whiteBloodCells: 3.2,
        LabMetric.platelets: 180.0,
        LabMetric.hemoglobin: 8.7,
      });
    });

    test('alt-unit selection is ignored for metrics without one', () {
      final values = ManualEntryController.parseValues(
        {LabMetric.hemoglobin: '8.7'},
        inAltUnit: {LabMetric.hemoglobin},
      );
      expect(values, {LabMetric.hemoglobin: 8.7});
    });
  });

  group('LabMetric alternate units', () {
    test('only WBC and platelets carry an Indian-report alternate unit', () {
      final withAlt =
          LabMetric.values.where((m) => m.altUnit != null).toSet();
      expect(withAlt,
          {LabMetric.whiteBloodCells, LabMetric.platelets});
      expect(LabMetric.whiteBloodCells.altUnit, 'cells/cumm');
      expect(LabMetric.platelets.altUnit, 'lakh/cumm');
    });

    test('alt range display matches Indian report conventions', () {
      expect(LabMetric.whiteBloodCells.formatAltRange(), '4000 - 11000');
      expect(LabMetric.platelets.formatAltRange(), '1.50 - 4.50');
    });
  });
}
