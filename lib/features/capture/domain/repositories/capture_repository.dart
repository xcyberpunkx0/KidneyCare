import '../../../../core/services/scan_page.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/document_type.dart';
import '../entities/extraction.dart';

/// Extraction and persistence for the capture flow. A document is a list
/// of page images — a single cropped photo or many pages from a batch
/// import.
abstract interface class CaptureRepository {
  /// Sends a lab report's pages, in order, for AI extraction.
  Future<Result<ExtractionResult>> extract(List<ScanPage> pages);

  /// Persists a reviewed lab report: stores the page images untouched,
  /// writes the document metadata, lab values, and a timeline entry.
  Future<Result<String>> saveReviewed({
    required List<ScanPage> pages,
    required ExtractionResult reviewed,
  });

  /// Persists a non-lab document exactly as photographed, with details
  /// the caregiver typed. No AI is involved: only the document row and
  /// a timeline entry are written.
  Future<Result<String>> saveManual({
    required List<ScanPage> pages,
    required DocumentType type,
    required String title,
    String doctor = '',
    required DateTime documentDate,
  });
}
