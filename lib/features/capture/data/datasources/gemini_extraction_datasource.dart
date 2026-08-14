import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/gemini_client.dart';
import '../../../../core/utils/app_failure.dart';
import '../models/extraction_dto.dart';

/// Sends a document photo to Gemini and parses the structured reply.
class GeminiExtractionDatasource {
  GeminiExtractionDatasource(this._client);

  final GeminiClient _client;

  static const _systemInstruction = '''
You extract structured data from photos of Indian medical documents
(prescriptions, lab reports, discharge summaries, hospital bills,
handwritten notes) for a dialysis patient's medical vault.

Return ONLY a JSON object with this exact shape:
{
  "document_type": "labReport" | "prescription" | "dischargeSummary" | "bill" | "handwrittenNote" | "scan",
  "title": "short human title, e.g. 'Monthly blood panel'",
  "hospital": "clinic/lab/hospital name or empty string",
  "doctor": "doctor name with specialty if printed, else empty",
  "document_date": "YYYY-MM-DD or null if not visible",
  "tags": ["up to 4 short topic tags"],
  "ocr_text": "the legible text of the document, condensed",
  "fields": [
    {
      "key": "machine_key",
      "label": "SHORT LABEL",
      "value": "extracted value",
      "confidence": 0.0-1.0,
      "note": "only when confidence < 0.75: what was hard to read and what it could be instead",
      "alternatives": ["plausible alternative readings, max 2"]
    }
  ],
  "medicines": [
    {"name": "Drug strength", "dose": "e.g. 400 mg", "frequency": "e.g. 1-0-1", "instruction": "e.g. with food"}
  ],
  "lab_values": [
    {"metric_code": "hb|k|cr|alb|phos|ca|wt|bps|bpd", "value": 9.4}
  ]
}

Rules:
- Every important datum appears in "fields" so the caregiver can verify it.
- Confidence must be honest; illegible handwriting is low confidence.
- "medicines" only for prescriptions/discharge summaries.
- "lab_values" only when numeric lab results are printed. Use only the
  listed metric_code values; skip metrics not in the list.
- Dates in ISO format. Never invent data that is not on the paper.''';

  Future<ExtractionDto> extract(Uint8List jpegBytes) async {
    final json = await _client.generateJson(
      prompt: 'Extract this medical document.',
      imageBase64: base64Encode(jpegBytes),
      systemInstruction: _systemInstruction,
    );
    try {
      return ExtractionDto.fromJson(json);
    } catch (error, stackTrace) {
      throw ParsingFailure(cause: error, stackTrace: stackTrace);
    }
  }
}

final geminiExtractionDatasourceProvider =
    Provider<GeminiExtractionDatasource>((ref) {
  return GeminiExtractionDatasource(ref.watch(geminiClientProvider));
});
