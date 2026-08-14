/// Unified failure hierarchy for the whole app.
///
/// Every layer maps its errors into one of these before crossing a feature
/// boundary, so presentation code has a single vocabulary for what went
/// wrong and how to phrase it to a stressed caregiver.
sealed class AppFailure implements Exception {
  const AppFailure({required this.message, this.cause, this.stackTrace});

  /// Calm, user-presentable description of the failure.
  final String message;

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// Device is offline or the server could not be reached.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'You appear to be offline. '
        'Saved records are still available.',
    super.cause,
    super.stackTrace,
  });
}

/// The AI extraction service failed or returned an unusable response.
final class ExtractionFailure extends AppFailure {
  const ExtractionFailure({
    super.message = 'The document could not be read this time. '
        'The original image has been kept safe — please try again.',
    super.cause,
    super.stackTrace,
  });
}

/// The AI service responded, but its output could not be parsed.
final class ParsingFailure extends AppFailure {
  const ParsingFailure({
    super.message = 'The extracted information was incomplete. '
        'Please review the document manually.',
    super.cause,
    super.stackTrace,
  });
}

/// Local database read/write failed.
final class StorageFailure extends AppFailure {
  const StorageFailure({
    super.message = 'The record could not be saved on this device. '
        'Please try again.',
    super.cause,
    super.stackTrace,
  });
}

/// A required runtime permission (camera, photos) was denied.
final class PermissionFailure extends AppFailure {
  const PermissionFailure({
    super.message = 'Permission is needed to continue. '
        'You can grant it from system settings.',
    super.cause,
    super.stackTrace,
  });
}

/// Image could not be read, decoded, or processed.
final class ImageFailure extends AppFailure {
  const ImageFailure({
    super.message = 'The image could not be processed. '
        'Please retake the photo.',
    super.cause,
    super.stackTrace,
  });
}

/// Input failed validation before save.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({required super.message});
}

/// Anything not covered above.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({
    super.message = 'Something went wrong. Please try again.',
    super.cause,
    super.stackTrace,
  });
}
