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
}
