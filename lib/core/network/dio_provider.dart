import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'retry_interceptor.dart';

/// Configured HTTP client for the Gemini API. Logging is attached only in
/// debug builds and never prints request bodies (they contain medical data).
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.geminiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 90),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(RetryInterceptor(dio));
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (line) => debugPrint('[net] $line'),
      ),
    );
  }
  return dio;
});
