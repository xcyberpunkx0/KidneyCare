import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../utils/app_failure.dart';
import 'scan_page.dart';

/// A PDF file the user picked, before rasterization.
class PickedPdf {
  const PickedPdf({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Brings PDF files into the image-based capture pipeline: picks them
/// from the system file browser and rasterizes each page to a PNG. The
/// vault stores page images, never the PDF itself, so downstream
/// (storage, previews, extraction, viewer) stays uniform.
class PdfImport {
  /// A safety valve, not a real limit — keeps a stray 100-page file from
  /// exhausting memory and the extraction request budget.
  static const maxPages = 15;

  /// Renders A4 at ~1240 px wide, comfortably inside the 2400 px budget
  /// the photo path uses while staying readable for extraction.
  static const _dpi = 150.0;

  /// Returns an empty list when the user cancels.
  Future<List<PickedPdf>> pickPdfs() async {
    final FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: true,
        withData: true,
      );
    } catch (error, stackTrace) {
      throw PermissionFailure(
        message: 'Files could not be opened. Check storage permission in '
            'system settings.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (result == null) return const [];
    return [
      for (final file in result.files)
        if (file.bytes != null)
          PickedPdf(name: file.name, bytes: file.bytes!),
    ];
  }

  /// Rasterizes every page of [pdf] to a PNG [ScanPage], in order.
  Future<List<ScanPage>> rasterize(PickedPdf pdf) async {
    final pages = <ScanPage>[];
    try {
      await for (final raster in Printing.raster(pdf.bytes, dpi: _dpi)) {
        if (pages.length >= maxPages) {
          throw ValidationFailure(
            message: '"${pdf.name}" has more than $maxPages pages. Please '
                'split it into smaller PDFs and import those.',
          );
        }
        pages.add(ScanPage.png(await raster.toPng()));
      }
    } on AppFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw ImageFailure(cause: error, stackTrace: stackTrace);
    }
    if (pages.isEmpty) {
      throw ValidationFailure(
        message: '"${pdf.name}" could not be read as a PDF.',
      );
    }
    return pages;
  }
}

final pdfImportProvider = Provider<PdfImport>((ref) => PdfImport());
