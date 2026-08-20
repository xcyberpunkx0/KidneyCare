import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/services/gemini_client.dart';
import 'package:recora/core/utils/app_failure.dart';

void main() {
  DioException httpError(int statusCode) {
    final options = RequestOptions(path: '/models/x:generateContent');
    return DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: options, statusCode: statusCode),
    );
  }

  test('connection problems map to NetworkFailure', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionError,
    );
    expect(GeminiClient.mapDioException(error), isA<NetworkFailure>());
  });

  test('auth errors name the API key as the fix', () {
    for (final status in [400, 401, 403]) {
      final failure = GeminiClient.mapDioException(httpError(status));
      expect(failure, isA<ExtractionFailure>());
      expect(failure.message, contains('key'),
          reason: 'HTTP $status should point at the key in Settings');
    }
  });

  test('429 explains the quota and asks to wait', () {
    final failure = GeminiClient.mapDioException(httpError(429));
    expect(failure.message.toLowerCase(), contains('quota'));
  });

  test('server errors ask to retry shortly', () {
    final failure = GeminiClient.mapDioException(httpError(503));
    expect(failure.message.toLowerCase(), contains('try again'));
  });

  test('anything else keeps the calm generic message', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.cancel,
    );
    final failure = GeminiClient.mapDioException(error);
    expect(failure, isA<ExtractionFailure>());
    expect(failure.message, contains('could not be read'));
  });

  test('each image becomes its own inline_data part, before the prompt',
      () async {
    late Map<String, dynamic> body;
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        body = options.data as Map<String, dynamic>;
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': '{"ok": true}'},
                  ],
                },
              },
            ],
          },
        ));
      },
    ));

    final json = await GeminiClient(dio, 'test-key').generateJson(
      prompt: 'Extract this medical document.',
      images: [
        (mimeType: 'image/png', base64: 'AAA'),
        (mimeType: 'image/jpeg', base64: 'BBB'),
        (mimeType: 'image/png', base64: 'CCC'),
      ],
    );

    expect(json, {'ok': true});
    final parts =
        ((body['contents'] as List).single as Map)['parts'] as List;
    expect(parts, hasLength(4));
    expect((parts[0] as Map)['inline_data'],
        {'mime_type': 'image/png', 'data': 'AAA'});
    expect((parts[1] as Map)['inline_data'],
        {'mime_type': 'image/jpeg', 'data': 'BBB'});
    expect((parts[2] as Map)['inline_data'],
        {'mime_type': 'image/png', 'data': 'CCC'});
    expect((parts[3] as Map)['text'], 'Extract this medical document.');
  });
}
