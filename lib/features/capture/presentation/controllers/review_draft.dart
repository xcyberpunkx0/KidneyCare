import 'package:flutter/foundation.dart';

import '../../domain/entities/extraction.dart';

/// One document's extraction under review: the raw result plus the
/// caregiver's edits and confirmations. Shared by the single capture
/// flow and the batch import queue so the trust rules stay identical.
@immutable
class ReviewDraft {
  const ReviewDraft({
    required this.extraction,
    this.editedValues = const {},
    this.verifiedKeys = const {},
  });

  final ExtractionResult extraction;

  /// Caregiver edits, keyed by field key.
  final Map<String, String> editedValues;

  /// Low/medium-confidence fields the caregiver has confirmed.
  final Set<String> verifiedKeys;

  /// Fields with caregiver edits applied.
  List<ExtractedField> get reviewFields => [
        for (final field in extraction.fields)
          field.copyWith(value: editedValues[field.key]),
      ];

  /// A field counts as checked when confidence is high, it was edited,
  /// or it was explicitly confirmed.
  bool isChecked(ExtractedField field) =>
      !field.requiresVerification ||
      verifiedKeys.contains(field.key) ||
      editedValues.containsKey(field.key);

  int get uncheckedCount => reviewFields.where((f) => !isChecked(f)).length;

  bool get allChecked => uncheckedCount == 0;

  ReviewDraft edit(String key, String value) => ReviewDraft(
        extraction: extraction,
        editedValues: {...editedValues, key: value},
        verifiedKeys: verifiedKeys,
      );

  ReviewDraft confirm(String key) => ReviewDraft(
        extraction: extraction,
        editedValues: editedValues,
        verifiedKeys: {...verifiedKeys, key},
      );

  ReviewDraft chooseAlternative(String key, String value) => ReviewDraft(
        extraction: extraction,
        editedValues: {...editedValues, key: value},
        verifiedKeys: {...verifiedKeys, key},
      );

  /// The extraction with all edits folded in, ready to persist.
  ExtractionResult reviewedResult() => ExtractionResult(
        documentType: extraction.documentType,
        title: extraction.title,
        hospital: extraction.hospital,
        doctor: extraction.doctor,
        documentDate: extraction.documentDate,
        fields: reviewFields,
        medicines: extraction.medicines,
        labValues: extraction.labValues,
        tags: extraction.tags,
        ocrText: extraction.ocrText,
      );
}
