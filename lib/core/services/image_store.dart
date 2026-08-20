import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/app_failure.dart';
import 'scan_page.dart';

/// Paths of a stored scan: the untouched original plus a small preview.
class StoredScan {
  const StoredScan({required this.originalPath, required this.previewPath});

  final String originalPath;
  final String previewPath;
}

/// Paths of a stored multi-page scan: one file per page plus a single
/// preview taken from the first page.
class StoredPages {
  const StoredPages({required this.pagePaths, required this.previewPath});

  final List<String> pagePaths;
  final String previewPath;
}

/// Persists captured document images. Originals are written byte-for-byte
/// as taken; a downscaled preview is generated for grids and lists.
class ImageStore {
  static const _previewWidth = 480;

  Future<StoredScan> persist(Uint8List originalBytes, String id) async {
    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final originalsDir =
          await Directory(p.join(baseDir.path, 'scans')).create(recursive: true);
      final previewsDir = await Directory(p.join(baseDir.path, 'previews'))
          .create(recursive: true);

      final originalPath = p.join(originalsDir.path, '$id.jpg');
      await File(originalPath).writeAsBytes(originalBytes, flush: true);

      final previewPath = p.join(previewsDir.path, '$id.png');
      final previewBytes = await _downscale(originalBytes);
      await File(previewPath).writeAsBytes(previewBytes, flush: true);

      return StoredScan(originalPath: originalPath, previewPath: previewPath);
    } on AppFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw ImageFailure(cause: error, stackTrace: stackTrace);
    }
  }

  /// Persists every page of a multi-page document as
  /// `scans/<id>_p<index>.<ext>`; the preview comes from the first page.
  Future<StoredPages> persistPages(List<ScanPage> pages, String id) async {
    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final originalsDir =
          await Directory(p.join(baseDir.path, 'scans')).create(recursive: true);
      final previewsDir = await Directory(p.join(baseDir.path, 'previews'))
          .create(recursive: true);

      final pagePaths = <String>[];
      for (var i = 0; i < pages.length; i++) {
        final page = pages[i];
        final path = p.join(originalsDir.path, '${id}_p$i.${page.extension}');
        await File(path).writeAsBytes(page.bytes, flush: true);
        pagePaths.add(path);
      }

      final previewPath = p.join(previewsDir.path, '$id.png');
      final previewBytes = await _downscale(pages.first.bytes);
      await File(previewPath).writeAsBytes(previewBytes, flush: true);

      return StoredPages(pagePaths: pagePaths, previewPath: previewPath);
    } on AppFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw ImageFailure(cause: error, stackTrace: stackTrace);
    }
  }

  Future<Uint8List> _downscale(Uint8List bytes) async {
    final codec =
        await ui.instantiateImageCodec(bytes, targetWidth: _previewWidth);
    final frame = await codec.getNextFrame();
    final data =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    if (data == null) {
      throw const ImageFailure();
    }
    return data.buffer.asUint8List();
  }
}

final imageStoreProvider = Provider<ImageStore>((ref) => ImageStore());
