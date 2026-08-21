import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../storage/app_database.dart';
import '../storage/database_provider.dart';
import '../utils/app_failure.dart';
import '../utils/result.dart';

/// Hands one stored document to the system share sheet: a single-page scan
/// goes out as its image file, a multi-page import is bundled into one PDF
/// so the receiver gets the whole document, not loose pages.
class DocumentShare {
  DocumentShare(this._db);

  final AppDatabase _db;

  Future<Result<void>> share(String documentId) {
    return Result.guard(() async {
      final doc = await _db.documentDao.getById(documentId);
      if (doc == null) {
        throw const StorageFailure(
          message: 'This document could not be found.',
        );
      }
      final pages = await _db.documentDao.pagesFor(documentId);
      final paths = resolvePagePaths(doc, pages)
          .where((path) => File(path).existsSync())
          .toList();
      if (paths.isEmpty) {
        throw const StorageFailure(
          message: 'The scanned image is no longer on this device, '
              'so there is nothing to share.',
        );
      }

      if (paths.length == 1) {
        final result = await Share.shareXFiles(
          [XFile(paths.single, mimeType: _mimeTypeFor(paths.single))],
          subject: doc.title,
        );
        if (result.status == ShareResultStatus.unavailable) {
          throw const StorageFailure(
            message: 'Sharing is not available on this device.',
          );
        }
        return;
      }

      final pdf = pw.Document();
      for (final path in paths) {
        final image = pw.MemoryImage(await File(path).readAsBytes());
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (context) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${sanitizeFileName(doc.title)}.pdf',
      );
    });
  }

  /// Files that make up the document, in reading order: page rows for a
  /// multi-page import, otherwise the single original scan.
  static List<String> resolvePagePaths(
    Document doc,
    List<DocumentPage> pages,
  ) {
    if (pages.isNotEmpty) {
      return [for (final page in pages) page.originalPath];
    }
    if (doc.originalPath.isEmpty) return const [];
    return [doc.originalPath];
  }

  /// Turns a document title into a safe cross-platform file name.
  static String sanitizeFileName(String title) {
    final cleaned = title
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    return cleaned.isEmpty ? 'document' : cleaned;
  }

  static String _mimeTypeFor(String path) =>
      path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
}

final documentShareProvider = Provider<DocumentShare>((ref) {
  return DocumentShare(ref.watch(databaseProvider));
});
