import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/utils/app_failure.dart';
import 'package:recora/core/utils/result.dart';

void main() {
  group('Result', () {
    test('ok carries the value', () {
      const result = Result.ok(42);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('err carries the failure', () {
      const result = Result<int>.err(NetworkFailure());
      expect(result.isOk, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('when dispatches to the right branch', () {
      const ok = Result.ok('value');
      const err = Result<String>.err(StorageFailure());
      expect(ok.when(ok: (v) => v, err: (_) => 'failed'), 'value');
      expect(err.when(ok: (v) => v, err: (_) => 'failed'), 'failed');
    });

    test('map transforms only success', () {
      expect(const Result.ok(2).map((v) => v * 3).valueOrNull, 6);
      final mapped = const Result<int>.err(ParsingFailure()).map((v) => v * 3);
      expect(mapped.failureOrNull, isA<ParsingFailure>());
    });

    test('guard converts thrown AppFailure into Err', () async {
      final result = await Result.guard<int>(
        () async => throw const ExtractionFailure(),
      );
      expect(result.failureOrNull, isA<ExtractionFailure>());
    });

    test('guard wraps unexpected errors', () async {
      final result =
          await Result.guard<int>(() async => throw StateError('boom'));
      expect(result.failureOrNull, isA<UnexpectedFailure>());
    });
  });
}
