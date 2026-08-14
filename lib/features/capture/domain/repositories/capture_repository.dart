import 'dart:typed_data';

import '../../../../core/utils/result.dart';
import '../entities/extraction.dart';

/// Extraction and persistence for the capture flow.
abstract interface class CaptureRepository {
  /// Sends the cropped photo for AI extraction.
  Future<Result<ExtractionResult>> extract(Uint8List jpegBytes);

  /// Persists the reviewed result: stores the image untouched, writes the
  /// document metadata, lab values, medicines, and a timeline entry.
  Future<Result<String>> saveReviewed({
    required Uint8List originalBytes,
    required ExtractionResult reviewed,
  });
}
