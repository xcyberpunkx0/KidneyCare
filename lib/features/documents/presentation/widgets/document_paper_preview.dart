import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../shared/domain/document_type.dart';

/// Document thumbnail: the stored preview image when one exists, otherwise
/// a warm paper placeholder sketched to match the document type.
class DocumentPaperPreview extends StatelessWidget {
  const DocumentPaperPreview({
    super.key,
    required this.type,
    this.previewPath = '',
    this.height = 106,
  });

  final DocumentType type;
  final String previewPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (previewPath.isNotEmpty && File(previewPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(previewPath),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          cacheHeight: (height * 3).round(),
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final handwritten = type == DocumentType.handwrittenNote ||
        type == DocumentType.prescription;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _PaperPainter(handwritten: handwritten),
        ),
      ),
    );
  }
}

/// Sketches a paper document: straight skeleton lines for printed pages,
/// wavy strokes for handwritten ones. Paper stays warm in both themes —
/// it depicts physical paper, not a UI surface.
class _PaperPainter extends CustomPainter {
  const _PaperPainter({required this.handwritten});

  final bool handwritten;

  static const _printedPaper = Color(0xFFF7F5EE);
  static const _printedHeading = Color(0xFFC9C2B4);
  static const _printedLine = Color(0xFFDDD7CB);
  static const _writtenPaper = Color(0xFFF4F0E6);
  static const _writtenHeading = Color(0xFFC8C0AE);
  static const _writtenStroke = Color(0xFFB8AE96);

  @override
  void paint(Canvas canvas, Size size) {
    final paper = Paint()
      ..color = handwritten ? _writtenPaper : _printedPaper;
    canvas.drawRect(Offset.zero & size, paper);

    final heading = Paint()
      ..color = handwritten ? _writtenHeading : _printedHeading;
    RRect line(double x, double y, double w, double h) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(3),
        );

    canvas.drawRRect(line(12, 12, size.width * 0.45, 6), heading);

    if (handwritten) {
      final stroke = Paint()
        ..color = _writtenStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final w = size.width - 24;
      for (final (y, fraction) in [(34.0, 1.0), (50.0, 0.95), (66.0, 0.45)]) {
        final path = Path()..moveTo(12, y);
        final span = w * fraction;
        path.quadraticBezierTo(12 + span * 0.25, y - 6, 12 + span * 0.5, y);
        path.quadraticBezierTo(
            12 + span * 0.75, y + 6, 12 + span, y - 2);
        canvas.drawPath(path, stroke);
      }
      canvas.drawRRect(line(12, size.height - 20, 45, 5), heading);
    } else {
      final body = Paint()..color = _printedLine;
      final widths = [0.85, 0.7, 0.8, 0.55];
      for (var i = 0; i < widths.length; i++) {
        canvas.drawRRect(
          line(12, 28 + i * 12, (size.width - 24) * widths[i], 4),
          body,
        );
      }
      canvas.drawRRect(line(12, size.height - 22, 55, 5), heading);
    }
  }

  @override
  bool shouldRepaint(_PaperPainter oldDelegate) =>
      oldDelegate.handwritten != handwritten;
}
