import '../../../../core/services/scan_page.dart';
import '../../../../core/utils/result.dart';
import '../entities/extraction.dart';

/// Extraction and persistence for the capture flow. A document is a list
/// of page images — a single cropped photo or many pages from a batch
/// import.
abstract interface class CaptureRepository {
  /// Sends the document's pages, in order, for AI extraction.
  Future<Result<ExtractionResult>> extract(List<ScanPage> pages);

  /// Persists the reviewed result: stores the page images untouched,
  /// writes the document metadata, lab values, medicines, and a
  /// timeline entry.
  Future<Result<String>> saveReviewed({
    required List<ScanPage> pages,
    required ExtractionResult reviewed,
  });
}
