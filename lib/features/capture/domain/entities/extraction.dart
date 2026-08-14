import '../../../../shared/domain/document_type.dart';

/// Confidence banding for extracted fields. Thresholds mirror the review
/// UI: high reads green, medium reads amber, low is highlighted and must
/// be verified before saving.
enum ConfidenceLevel {
  high,
  medium,
  low;

  static ConfidenceLevel fromScore(double score) {
    if (score >= 0.85) return ConfidenceLevel.high;
    if (score >= 0.70) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }
}

/// One editable field on the review screen.
class ExtractedField {
  const ExtractedField({
    required this.key,
    required this.label,
    required this.value,
    required this.confidence,
    this.note = '',
    this.alternatives = const [],
  });

  final String key;

  /// Uppercase card label, e.g. "MEDICINE 1".
  final String label;

  final String value;

  /// 0–1 model confidence.
  final double confidence;

  /// Helper shown under low-confidence values, e.g.
  /// "Dose was hard to read — could be 4,000 IU."
  final String note;

  /// Competing readings the caregiver can pick between.
  final List<String> alternatives;

  ConfidenceLevel get level => ConfidenceLevel.fromScore(confidence);

  /// Low-confidence fields must be explicitly verified before save.
  bool get requiresVerification => level != ConfidenceLevel.high;

  ExtractedField copyWith({String? value}) {
    return ExtractedField(
      key: key,
      label: label,
      value: value ?? this.value,
      confidence: confidence,
      note: note,
      alternatives: alternatives,
    );
  }
}

/// A medicine row parsed from a prescription.
class ExtractedMedicine {
  const ExtractedMedicine({
    required this.name,
    required this.dose,
    required this.frequency,
    this.instruction = '',
  });

  final String name;
  final String dose;
  final String frequency;
  final String instruction;
}

/// A numeric lab observation parsed from a report.
class ExtractedLabValue {
  const ExtractedLabValue({required this.metricCode, required this.value});

  final String metricCode;
  final double value;
}

/// Structured result of a Gemini document extraction.
class ExtractionResult {
  const ExtractionResult({
    required this.documentType,
    required this.title,
    required this.hospital,
    required this.doctor,
    required this.documentDate,
    required this.fields,
    this.medicines = const [],
    this.labValues = const [],
    this.tags = const [],
    this.ocrText = '',
  });

  final DocumentType documentType;
  final String title;
  final String hospital;
  final String doctor;
  final DateTime documentDate;
  final List<ExtractedField> fields;
  final List<ExtractedMedicine> medicines;
  final List<ExtractedLabValue> labValues;
  final List<String> tags;
  final String ocrText;
}
