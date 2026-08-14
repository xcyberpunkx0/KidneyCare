import 'package:dio/dio.dart';

/// Retries idempotent requests that failed with a transient error, with
/// exponential backoff. Non-transient failures pass through untouched.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  static const _retryKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryKey] as int?) ?? 0;
    if (!_isTransient(err) || attempt >= maxRetries) {
      return handler.next(err);
    }

    await Future<void>.delayed(Duration(milliseconds: 500 * (1 << attempt)));
    final options = err.requestOptions
      ..extra[_retryKey] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  bool _isTransient(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode;
    return status == 429 || status == 502 || status == 503 || status == 504;
  }
}
