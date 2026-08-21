import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/services/document_share.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/shared/domain/document_type.dart';

Document _doc({String originalPath = ''}) {
  return Document(
    id: 'doc-1',
    type: DocumentType.labReport,
    title: 'KFT Report',
    hospital: '',
    doctor: '',
    documentDate: DateTime(2026, 8, 1),
    capturedAt: DateTime(2026, 8, 1),
    originalPath: originalPath,
    previewPath: '',
    ocrText: '',
    tagsJson: '[]',
    note: '',
  );
}

DocumentPage _page(int index, String path) {
  return DocumentPage(
    id: 'page-$index',
    documentId: 'doc-1',
    pageIndex: index,
    originalPath: path,
  );
}

void main() {
  group('DocumentShare.resolvePagePaths', () {
    test('multi-page document uses page rows in order', () {
      final paths = DocumentShare.resolvePagePaths(
        _doc(originalPath: '/scans/doc-1_p0.jpg'),
        [_page(0, '/scans/doc-1_p0.jpg'), _page(1, '/scans/doc-1_p1.jpg')],
      );
      expect(paths, ['/scans/doc-1_p0.jpg', '/scans/doc-1_p1.jpg']);
    });

    test('single-page document falls back to originalPath', () {
      final paths =
          DocumentShare.resolvePagePaths(_doc(originalPath: '/a.jpg'), []);
      expect(paths, ['/a.jpg']);
    });

    test('document without any image resolves to nothing', () {
      expect(DocumentShare.resolvePagePaths(_doc(), []), isEmpty);
    });
  });

  group('DocumentShare.sanitizeFileName', () {
    test('strips unsafe characters and joins words with dashes', () {
      expect(
        DocumentShare.sanitizeFileName('Dr. Iyer: KFT / August'),
        'Dr-Iyer-KFT-August',
      );
    });

    test('falls back when nothing safe remains', () {
      expect(DocumentShare.sanitizeFileName('///'), 'document');
    });
  });
}
