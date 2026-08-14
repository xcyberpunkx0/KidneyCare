import 'app_failure.dart';

/// A value that is either a success ([Ok]) or a failure ([Err]).
///
/// Repositories and use cases return [Result] instead of throwing, so every
/// caller is forced to handle the failure path explicitly.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.err(AppFailure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  T? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Ok() => null,
        Err(:final failure) => failure,
      };

  R when<R>({
    required R Function(T value) ok,
    required R Function(AppFailure failure) err,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Err(:final failure) => err(failure),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok(:final value) => Result.ok(transform(value)),
      Err(:final failure) => Result.err(failure),
    };
  }

  /// Runs [body], converting thrown [AppFailure]s and unexpected errors
  /// into an [Err].
  static Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      return Result.ok(await body());
    } on AppFailure catch (failure) {
      return Result.err(failure);
    } catch (error, stackTrace) {
      return Result.err(UnexpectedFailure(cause: error, stackTrace: stackTrace));
    }
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final AppFailure failure;
}
