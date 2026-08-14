import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/gemini_client.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../shared/domain/lab_metric.dart';

/// The model's reply: an answer plus the ids of documents it drew from.
class AskReply {
  const AskReply({required this.answer, required this.citedDocumentIds});

  final String answer;
  final List<String> citedDocumentIds;
}

/// Queries Gemini with the vault contents as grounding context.
class GeminiAskDatasource {
  GeminiAskDatasource(this._client);

  final GeminiClient _client;

  static const _systemInstruction = '''
You answer a caregiver's questions about one dialysis patient using ONLY
the medical vault records provided in the prompt. You are careful, calm
and specific. If the records do not contain the answer, say so plainly.

Return ONLY JSON: {"answer": "plain text, no markdown, cite dates and
numbers precisely", "citations": ["document ids you used"]}

Never give treatment advice; describe what the records say and remind the
caregiver to confirm decisions with the treating doctor.''';

  Future<AskReply> ask({
    required String question,
    required Patient? patient,
    required List<Document> documents,
    required List<Medication> medications,
    required List<LabResult> labs,
  }) async {
    final context = _buildContext(
      patient: patient,
      documents: documents,
      medications: medications,
      labs: labs,
    );
    final json = await _client.generateJson(
      prompt: '$context\n\nQuestion: $question',
      systemInstruction: _systemInstruction,
    );
    final citations = json['citations'];
    return AskReply(
      answer: (json['answer'] as String?) ??
          'The records do not contain an answer to that.',
      citedDocumentIds: citations is List
          ? citations.whereType<String>().toList()
          : const [],
    );
  }

  String _buildContext({
    required Patient? patient,
    required List<Document> documents,
    required List<Medication> medications,
    required List<LabResult> labs,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final buffer = StringBuffer('MEDICAL VAULT\n');

    if (patient != null) {
      buffer.writeln('Patient: ${patient.name}, ${patient.age}, '
          '${patient.conditionSummary}, dry weight '
          '${patient.dryWeightKg} kg, ${patient.dialysisCenter}');
      if (patient.comorbidities.isNotEmpty) {
        buffer.writeln('Other conditions: ${patient.comorbidities}');
      }
      if (patient.allergies.isNotEmpty) {
        buffer.writeln('Allergies: ${patient.allergies}');
      }
    }

    buffer.writeln('\nMEDICATIONS:');
    for (final med in medications) {
      final status = med.endDate == null
          ? 'active'
          : 'ended ${dateFormat.format(med.endDate!)}';
      buffer.writeln('- ${med.name} (${med.frequencyCode}, '
          '${med.purpose}, ${med.doctor}, $status)');
    }

    buffer.writeln('\nLAB HISTORY (metric, date, value):');
    for (final lab in labs) {
      final metric = LabMetric.fromCode(lab.metricCode);
      buffer.writeln('- ${metric?.label ?? lab.metricCode} '
          '${dateFormat.format(lab.takenAt)}: ${lab.value} '
          '${metric?.unit ?? ''}');
    }

    buffer.writeln('\nDOCUMENTS:');
    for (final doc in documents) {
      buffer.writeln('[id=${doc.id}] ${doc.type.name} · ${doc.title} · '
          '${doc.hospital} · ${doc.doctor} · '
          '${dateFormat.format(doc.documentDate)}');
      if (doc.ocrText.isNotEmpty) {
        final text = doc.ocrText.length > 600
            ? '${doc.ocrText.substring(0, 600)}…'
            : doc.ocrText;
        buffer.writeln('  text: $text');
      }
    }
    return buffer.toString();
  }
}

final geminiAskDatasourceProvider = Provider<GeminiAskDatasource>((ref) {
  return GeminiAskDatasource(ref.watch(geminiClientProvider));
});
