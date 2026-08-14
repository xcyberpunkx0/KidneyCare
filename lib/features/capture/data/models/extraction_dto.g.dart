// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extraction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExtractionDto _$ExtractionDtoFromJson(Map<String, dynamic> json) =>
    _ExtractionDto(
      documentType: json['document_type'] as String? ?? 'scan',
      title: json['title'] as String? ?? '',
      hospital: json['hospital'] as String? ?? '',
      doctor: json['doctor'] as String? ?? '',
      documentDate: json['document_date'] as String?,
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => FieldDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      medicines:
          (json['medicines'] as List<dynamic>?)
              ?.map((e) => MedicineDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      labValues:
          (json['lab_values'] as List<dynamic>?)
              ?.map((e) => LabValueDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      ocrText: json['ocr_text'] as String? ?? '',
    );

Map<String, dynamic> _$ExtractionDtoToJson(_ExtractionDto instance) =>
    <String, dynamic>{
      'document_type': instance.documentType,
      'title': instance.title,
      'hospital': instance.hospital,
      'doctor': instance.doctor,
      'document_date': instance.documentDate,
      'fields': instance.fields,
      'medicines': instance.medicines,
      'lab_values': instance.labValues,
      'tags': instance.tags,
      'ocr_text': instance.ocrText,
    };

_FieldDto _$FieldDtoFromJson(Map<String, dynamic> json) => _FieldDto(
  key: json['key'] as String? ?? '',
  label: json['label'] as String? ?? '',
  value: json['value'] as String? ?? '',
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
  note: json['note'] as String? ?? '',
  alternatives:
      (json['alternatives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$FieldDtoToJson(_FieldDto instance) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'value': instance.value,
  'confidence': instance.confidence,
  'note': instance.note,
  'alternatives': instance.alternatives,
};

_MedicineDto _$MedicineDtoFromJson(Map<String, dynamic> json) => _MedicineDto(
  name: json['name'] as String? ?? '',
  dose: json['dose'] as String? ?? '',
  frequency: json['frequency'] as String? ?? '',
  instruction: json['instruction'] as String? ?? '',
);

Map<String, dynamic> _$MedicineDtoToJson(_MedicineDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dose': instance.dose,
      'frequency': instance.frequency,
      'instruction': instance.instruction,
    };

_LabValueDto _$LabValueDtoFromJson(Map<String, dynamic> json) => _LabValueDto(
  metricCode: json['metric_code'] as String? ?? '',
  value: (json['value'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LabValueDtoToJson(_LabValueDto instance) =>
    <String, dynamic>{
      'metric_code': instance.metricCode,
      'value': instance.value,
    };
