import 'package:flutter_test/flutter_test.dart';
import 'package:recora/features/capture/domain/entities/extraction.dart';
import 'package:recora/features/capture/presentation/controllers/capture_flow_controller.dart';
import 'package:recora/shared/domain/document_type.dart';

ExtractionResult _extraction() {
  return ExtractionResult(
    documentType: DocumentType.prescription,
    title: 'Rx',
    hospital: 'Kaveri',
    doctor: 'Dr. Menon',
    documentDate: DateTime(2026, 8, 2),
    fields: const [
      ExtractedField(
        key: 'doctor',
        label: 'DOCTOR',
        value: 'Dr. Menon',
        confidence: 0.98,
      ),
      ExtractedField(
        key: 'medicine_1',
        label: 'MEDICINE 1',
        value: 'Wepox 10,000 IU',
        confidence: 0.67,
      ),
      ExtractedField(
        key: 'medicine_2',
        label: 'MEDICINE 2',
        value: 'Torsemide 20 mg',
        confidence: 0.54,
      ),
    ],
  );
}

void main() {
  group('CaptureFlowState verification gate', () {
    test('uncertain fields block saving until checked', () {
      final state = CaptureFlowState(extraction: _extraction());
      expect(state.uncheckedCount, 2);
      expect(state.allChecked, isFalse);
    });

    test('explicit confirmation clears a field', () {
      final state = CaptureFlowState(
        extraction: _extraction(),
        verifiedKeys: const {'medicine_1'},
      );
      expect(state.uncheckedCount, 1);
    });

    test('editing a field counts as checking it', () {
      final state = CaptureFlowState(
        extraction: _extraction(),
        editedValues: const {
          'medicine_1': 'Wepox 4,000 IU',
          'medicine_2': 'Torsemide 20 mg — 1-0-0',
        },
      );
      expect(state.allChecked, isTrue);
      expect(
        state.reviewFields.firstWhere((f) => f.key == 'medicine_1').value,
        'Wepox 4,000 IU',
      );
    });

    test('high-confidence fields never block', () {
      final state = CaptureFlowState(extraction: _extraction());
      final doctor =
          state.reviewFields.firstWhere((f) => f.key == 'doctor');
      expect(state.isChecked(doctor), isTrue);
    });
  });
}
