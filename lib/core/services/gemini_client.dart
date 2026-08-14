import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_config.dart';
import '../network/dio_provider.dart';
import '../utils/app_failure.dart';
import 'gemini_key_store.dart';

/// Thin client over the Gemini generateContent API.
///
/// Both the capture extraction and Ask-AI features build on this. It only
/// knows how to send content and demand JSON back — prompt construction
/// stays inside each feature's datasource.
class GeminiClient {
  GeminiClient(this._dio, this._apiKey);

  final Dio _dio;
  final String _apiKey;

  /// Sends [prompt] (optionally with an inline [imageBase64] JPEG) and
  /// returns the decoded JSON object the model was instructed to produce.
  Future<Map<String, dynamic>> generateJson({
    required String prompt,
    String? imageBase64,
    String? systemInstruction,
  }) async {
    if (_apiKey.isEmpty) {
      throw const ExtractionFailure(
        message: 'AI features need a Gemini API key. '
            'Paste yours in Settings — free at aistudio.google.com.',
      );
    }

    final parts = <Map<String, dynamic>>[
      if (imageBase64 != null)
        {
          'inline_data': {'mime_type': 'image/jpeg', 'data': imageBase64},
        },
      {'text': prompt},
    ];

    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        ApiConfig.generateContentPath,
        queryParameters: {'key': _apiKey},
        data: {
          if (systemInstruction != null)
            'system_instruction': {
              'parts': [
                {'text': systemInstruction},
              ],
            },
          'contents': [
            {'role': 'user', 'parts': parts},
          ],
          'generationConfig': {
            'response_mime_type': 'application/json',
            'temperature': 0.1,
          },
        },
      );
    } on DioException catch (error, stackTrace) {
      throw switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout =>
          NetworkFailure(cause: error, stackTrace: stackTrace),
        _ => ExtractionFailure(cause: error, stackTrace: stackTrace),
      };
    }

    final text = _firstCandidateText(response.data);
    if (text == null) {
      throw ParsingFailure(cause: response.data);
    }
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } on FormatException catch (error, stackTrace) {
      throw ParsingFailure(cause: error, stackTrace: stackTrace);
    }
  }

  String? _firstCandidateText(Map<String, dynamic>? body) {
    final candidates = body?['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final content = (candidates.first as Map<String, dynamic>)['content'];
    if (content is! Map<String, dynamic>) return null;
    final parts = content['parts'];
    if (parts is! List) return null;
    // Thinking models may emit thought parts before the answer — take
    // the first non-thought part that carries text.
    for (final part in parts.whereType<Map<String, dynamic>>()) {
      if (part['thought'] == true) continue;
      final text = part['text'];
      if (text is String && text.isNotEmpty) return text;
    }
    return null;
  }
}

final geminiClientProvider = Provider<GeminiClient>((ref) {
  // The key pasted in Settings wins; a bundled .env / --dart-define key
  // (developer builds only) is the fallback.
  final userKey = ref.watch(geminiKeyProvider);
  final apiKey = userKey.isNotEmpty ? userKey : ApiConfig.geminiApiKey;
  return GeminiClient(ref.watch(dioProvider), apiKey);
});
