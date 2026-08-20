import 'dart:typed_data';

/// One page image of a document on its way into the vault: raw bytes
/// plus the mime type they are encoded with. Camera/gallery photos are
/// JPEG; pages rasterized from a PDF are PNG.
class ScanPage {
  const ScanPage({required this.bytes, required this.mimeType});

  const ScanPage.jpeg(this.bytes) : mimeType = 'image/jpeg';

  const ScanPage.png(this.bytes) : mimeType = 'image/png';

  final Uint8List bytes;
  final String mimeType;

  /// File extension matching [mimeType], without the dot.
  String get extension => mimeType == 'image/png' ? 'png' : 'jpg';
}
