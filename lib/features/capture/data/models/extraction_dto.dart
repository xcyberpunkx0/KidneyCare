import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../shared/domain/document_type.dart';
import '../../domain/entities/extraction.dart';

part 'extraction_dto.freezed.dart';
part 'extraction_dto.g.dart';

/// Wire format of the JSON Gemini is instructed to return. Kept separate
/// from the domain [ExtractionResult] so prompt/schema changes never leak
/// past the data layer.
@freezed
abstract class ExtractionDto with _$ExtractionDto {
  const factory ExtractionDto({
    @JsonKey(name: 'document_type') @Default('scan') String documentType,
    @Default('') String title,
    @Default('') String hospital,
    @Default('') String doctor,
    @JsonKey(name: 'document_date') String? documentDate,
    @Default([]) List<FieldDto> fields,
    @Default([]) List<MedicineDto> medicines,
    @JsonKey(name: 'lab_values') @Default([]) List<LabValueDto> labValues,
    @Default([]) List<String> tags,
    @JsonKey(name: 'ocr_text') @Default('') String ocrText,
  }) = _ExtractionDto;

  const ExtractionDto._();

  factory ExtractionDto.fromJson(Map<String, dynamic> json) =>
      _$ExtractionDtoFromJson(json);

  ExtractionResult toDomain() {
    return ExtractionResult(
      documentType: DocumentType.values.asNameMap()[documentType] ??
          DocumentType.scan,
      title: title.isEmpty ? 'Captured document' : title,
      hospital: hospital,
      doctor: doctor,
      documentDate:
          DateTime.tryParse(documentDate ?? '') ?? DateTime.now(),
      fields: [for (final field in fields) field.toDomain()],
      medicines: [for (final med in medicines) med.toDomain()],
      labValues: [
        for (final lab in labValues)
          if (lab.value != null)
            ExtractedLabValue(
              metricCode: lab.metricCode,
              value: lab.value!,
            ),
      ],
      tags: tags,
      ocrText: ocrText,
    );
  }
}

@freezed
abstract class FieldDto with _$FieldDto {
  const factory FieldDto({
    @Default('') String key,
    @Default('') String label,
    @Default('') String value,
    @Default(0.5) double confidence,
    @Default('') String note,
    @Default([]) List<String> alternatives,
  }) = _FieldDto;

  const FieldDto._();

  factory FieldDto.fromJson(Map<String, dynamic> json) =>
      _$FieldDtoFromJson(json);

  ExtractedField toDomain() {
    return ExtractedField(
      key: key.isEmpty ? label.toLowerCase() : key,
      label: label.isEmpty ? key.toUpperCase() : label.toUpperCase(),
      value: value,
      confidence: confidence.clamp(0.0, 1.0),
      note: note,
      alternatives: alternatives,
    );
  }
}

@freezed
abstract class MedicineDto with _$MedicineDto {
  const factory MedicineDto({
    @Default('') String name,
    @Default('') String dose,
    @Default('') String frequency,
    @Default('') String instruction,
  }) = _MedicineDto;

  const MedicineDto._();

  factory MedicineDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineDtoFromJson(json);

  ExtractedMedicine toDomain() {
    return ExtractedMedicine(
      name: name,
      dose: dose,
      frequency: frequency,
      instruction: instruction,
    );
  }
}

@freezed
abstract class LabValueDto with _$LabValueDto {
  const factory LabValueDto({
    @JsonKey(name: 'metric_code') @Default('') String metricCode,
    double? value,
  }) = _LabValueDto;

  factory LabValueDto.fromJson(Map<String, dynamic> json) =>
      _$LabValueDtoFromJson(json);
}
