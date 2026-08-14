import 'package:flutter_test/flutter_test.dart';
import 'package:recora/features/capture/data/models/extraction_dto.dart';
import 'package:recora/features/capture/domain/entities/extraction.dart';
import 'package:recora/shared/domain/document_type.dart';

void main() {
  group('ConfidenceLevel', () {
    test('bands match the review thresholds', () {
      expect(ConfidenceLevel.fromScore(0.98), ConfidenceLevel.high);
      expect(ConfidenceLevel.fromScore(0.85), ConfidenceLevel.high);
      expect(ConfidenceLevel.fromScore(0.75), ConfidenceLevel.medium);
      expect(ConfidenceLevel.fromScore(0.67), ConfidenceLevel.low);
      expect(ConfidenceLevel.fromScore(0.0), ConfidenceLevel.low);
    });

    test('only high confidence skips verification', () {
      const high = ExtractedField(
        key: 'doctor',
        label: 'DOCTOR',
        value: 'Dr. Menon',
        confidence: 0.98,
      );
      const low = ExtractedField(
        key: 'medicine_1',
        label: 'MEDICINE 1',
        value: 'Wepox 10,000 IU',
        confidence: 0.67,
      );
      expect(high.requiresVerification, isFalse);
      expect(low.requiresVerification, isTrue);
    });
  });

  group('ExtractionDto', () {
    test('parses the Gemini reply shape into the domain model', () {
      final dto = ExtractionDto.fromJson({
        'document_type': 'prescription',
        'title': 'EPO prescription',
        'hospital': 'Kaveri Hospital',
        'doctor': 'Dr. Menon',
        'document_date': '2026-08-02',
        'tags': ['Erythropoietin'],
        'ocr_text': 'Inj Wepox 10000 IU weekly',
        'fields': [
          {
            'key': 'medicine_1',
            'label': 'MEDICINE 1',
            'value': 'Wepox 10,000 IU',
            'confidence': 0.67,
            'note': 'Dose was hard to read',
            'alternatives': ['Wepox 4,000 IU'],
          },
        ],
        'medicines': [
          {
            'name': 'Wepox 10,000 IU',
            'dose': '10,000 IU',
            'frequency': 'weekly',
            'instruction': 's/c after dialysis',
          },
        ],
        'lab_values': [
          {'metric_code': 'hb', 'value': 9.4},
        ],
      });

      final domain = dto.toDomain();
      expect(domain.documentType, DocumentType.prescription);
      expect(domain.documentDate, DateTime(2026, 8, 2));
      expect(domain.fields.single.level, ConfidenceLevel.low);
      expect(domain.fields.single.alternatives, ['Wepox 4,000 IU']);
      expect(domain.medicines.single.frequency, 'weekly');
      expect(domain.labValues.single.metricCode, 'hb');
    });

    test('degrades gracefully on sparse replies', () {
      final domain = ExtractionDto.fromJson(const {}).toDomain();
      expect(domain.documentType, DocumentType.scan);
      expect(domain.title, 'Captured document');
      expect(domain.fields, isEmpty);
    });
  });
}
