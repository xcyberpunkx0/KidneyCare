import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recora/core/services/pdf_import.dart';
import 'package:recora/core/services/photo_picker.dart';
import 'package:recora/core/services/scan_page.dart';
import 'package:recora/core/utils/result.dart';
import 'package:recora/features/capture/data/repository_impl/capture_repository_impl.dart';
import 'package:recora/features/capture/domain/entities/extraction.dart';
import 'package:recora/features/capture/domain/repositories/capture_repository.dart';
import 'package:recora/features/claims/presentation/controllers/claim_edit_controller.dart';
import 'package:recora/shared/domain/document_type.dart';

class _FakeCaptureRepository implements CaptureRepository {
  final manualSaves = <({DocumentType type, String title, int pageCount})>[];

  @override
  Future<Result<ExtractionResult>> extract(List<ScanPage> pages) async =>
      throw UnimplementedError();

  @override
  Future<Result<String>> saveReviewed({
    required List<ScanPage> pages,
    required ExtractionResult reviewed,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Result<String>> saveManual({
    required List<ScanPage> pages,
    required DocumentType type,
    required String title,
    String doctor = '',
    required DateTime documentDate,
  }) async {
    manualSaves.add((type: type, title: title, pageCount: pages.length));
    return Result.ok('doc-${manualSaves.length}');
  }
}

class _FakePhotoPicker extends PhotoPicker {
  _FakePhotoPicker(this.photos) : super(ImagePicker());

  final List<Uint8List> photos;

  @override
  Future<List<Uint8List>> pickManyFromGallery() async => photos;
}

class _FakePdfImport extends PdfImport {
  _FakePdfImport(this.pdfs);

  final List<PickedPdf> pdfs;

  @override
  Future<List<PickedPdf>> pickPdfs() async => pdfs;

  @override
  Future<List<ScanPage>> rasterize(PickedPdf pdf) async =>
      [ScanPage.png(pdf.bytes), ScanPage.png(pdf.bytes)];
}

void main() {
  test('validate: empty title is rejected, trimmed title accepted', () {
    expect(ClaimEditController.validateTitle('   '), isFalse);
    expect(ClaimEditController.validateTitle('August bundle'), isTrue);
  });

  test('toggling ids in a selection set', () {
    const state = ClaimEditState(
      title: '',
      selectedDocumentIds: {'a'},
    );
    final toggledOn = state.withToggled('b');
    expect(toggledOn.selectedDocumentIds, {'a', 'b'});
    final toggledOff = toggledOn.withToggled('a');
    expect(toggledOff.selectedDocumentIds, {'b'});
  });

  test('copyWith round-trips the importing flag', () {
    const state = ClaimEditState(title: '', selectedDocumentIds: {});
    expect(state.importing, isFalse);
    expect(state.copyWith(importing: true).importing, isTrue);
  });

  (ProviderContainer, _FakeCaptureRepository) makeContainer({
    List<Uint8List> photos = const [],
    List<PickedPdf> pdfs = const [],
  }) {
    final repository = _FakeCaptureRepository();
    final container = ProviderContainer(overrides: [
      captureRepositoryProvider.overrideWithValue(repository),
      photoPickerProvider.overrideWithValue(_FakePhotoPicker(photos)),
      pdfImportProvider.overrideWithValue(_FakePdfImport(pdfs)),
    ]);
    addTearDown(container.dispose);
    // Keep the autoDispose controller alive for the whole test.
    container.listen(claimEditControllerProvider, (_, _) {});
    return (container, repository);
  }

  test('importPhotosFromDevice saves each photo as a bill and selects it',
      () async {
    final (container, repository) = makeContainer(photos: [
      Uint8List.fromList([1]),
      Uint8List.fromList([2]),
    ]);
    final controller = container.read(claimEditControllerProvider.notifier);

    await controller.importPhotosFromDevice(defaultTitle: 'Bill photo');

    expect(repository.manualSaves, hasLength(2));
    expect(repository.manualSaves.first.type, DocumentType.bill);
    expect(repository.manualSaves.first.title, 'Bill photo');
    expect(repository.manualSaves.first.pageCount, 1);
    final state = container.read(claimEditControllerProvider);
    expect(state.selectedDocumentIds, {'doc-1', 'doc-2'});
    expect(state.importing, isFalse);
  });

  test('importPdfsFromDevice saves the PDF with its stripped filename',
      () async {
    final (container, repository) = makeContainer(pdfs: [
      PickedPdf(name: 'Chemist Bill.PDF', bytes: Uint8List.fromList([3])),
    ]);
    final controller = container.read(claimEditControllerProvider.notifier);

    await controller.importPdfsFromDevice();

    expect(repository.manualSaves, hasLength(1));
    expect(repository.manualSaves.single.type, DocumentType.bill);
    expect(repository.manualSaves.single.title, 'Chemist Bill');
    expect(repository.manualSaves.single.pageCount, 2);
    final state = container.read(claimEditControllerProvider);
    expect(state.selectedDocumentIds, {'doc-1'});
    expect(state.importing, isFalse);
  });

  test('cancelling the picker leaves the selection untouched', () async {
    final (container, repository) = makeContainer();
    final controller = container.read(claimEditControllerProvider.notifier);

    await controller.importPhotosFromDevice(defaultTitle: 'Bill photo');
    await controller.importPdfsFromDevice();

    expect(repository.manualSaves, isEmpty);
    final state = container.read(claimEditControllerProvider);
    expect(state.selectedDocumentIds, isEmpty);
    expect(state.importing, isFalse);
    expect(state.error, isNull);
  });
}
