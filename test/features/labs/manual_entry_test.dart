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
  });
}
