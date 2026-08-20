import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recora/core/services/photo_picker.dart';
import 'package:recora/core/services/scan_page.dart';
import 'package:recora/core/utils/app_failure.dart';
import 'package:recora/core/utils/result.dart';
import 'package:recora/features/capture/data/repository_impl/capture_repository_impl.dart';
import 'package:recora/features/capture/domain/entities/extraction.dart';
import 'package:recora/features/capture/domain/repositories/capture_repository.dart';
import 'package:recora/features/capture/presentation/controllers/batch_import_controller.dart';
import 'package:recora/shared/domain/document_type.dart';

/// A page whose first byte is [failMarker] makes the fake extraction fail.
const failMarker = 0xFF;

ExtractionResult _extraction({double confidence = 0.95}) {
  return ExtractionResult(
    documentType: DocumentType.labReport,
    title: 'Panel',
    hospital: '',
    doctor: '',
    documentDate: DateTime(2026, 8, 10),
    fields: [
      ExtractedField(
        key: 'hb',
        label: 'HB',
        value: '9.4',
        confidence: confidence,
      ),
    ],
  );
}

class _FakeRepository implements CaptureRepository {
  _FakeRepository({this.confidence = 0.95});

  final double confidence;
  final extractedPageCounts = <int>[];
  var savedCount = 0;

  @override
  Future<Result<ExtractionResult>> extract(List<ScanPage> pages) async {
    extractedPageCounts.add(pages.length);
    if (pages.first.bytes.first == failMarker) {
      return const Result.err(
          ExtractionFailure(message: 'unreadable scan'));
    }
    return Result.ok(_extraction(confidence: confidence));
  }

  @override
  Future<Result<String>> saveReviewed({
    required List<ScanPage> pages,
    required ExtractionResult reviewed,
  }) async {
    savedCount++;
    return Result.ok('doc-$savedCount');
  }
}

class _FakePhotoPicker extends PhotoPicker {
  _FakePhotoPicker(this.photos) : super(ImagePicker());

  final List<Uint8List> photos;

  @override
  Future<List<Uint8List>> pickManyFromGallery() async => photos;
}

void main() {
  Uint8List photo(int seed) => Uint8List.fromList([seed]);

  (ProviderContainer, _FakeRepository) makeContainer(
    List<Uint8List> photos, {
    double confidence = 0.95,
  }) {
    final repository = _FakeRepository(confidence: confidence);
    final container = ProviderContainer(overrides: [
      captureRepositoryProvider.overrideWithValue(repository),
      photoPickerProvider.overrideWithValue(_FakePhotoPicker(photos)),
    ]);
    addTearDown(container.dispose);
    // Keep the autoDispose controller alive for the whole test.
    container.listen(batchImportProvider, (_, _) {});
    return (container, repository);
  }

  test('addPhotos queues one pending item per photo, capped at 25',
      () async {
    final (container, _) =
        makeContainer([for (var i = 1; i <= 30; i++) photo(i)]);
    final controller = container.read(batchImportProvider.notifier);

    await controller.addPhotos();

    final state = container.read(batchImportProvider);
    expect(state.items, hasLength(BatchImportController.maxItems));
    expect(state.items.every((i) => i.status == BatchItemStatus.pending),
        isTrue);
    expect(state.failure, isA<ValidationFailure>());
  });

  test('start extracts every item; one failure does not stop the queue',
      () async {
    final (container, repository) =
        makeContainer([photo(1), photo(failMarker), photo(3)]);
    final controller = container.read(batchImportProvider.notifier);

    await controller.addPhotos();
    controller.start();
    await pumpEventQueue();

    final state = container.read(batchImportProvider);
    expect(repository.extractedPageCounts, [1, 1, 1]);
    expect(state.items[0].status, BatchItemStatus.ready);
    expect(state.items[1].status, BatchItemStatus.failed);
    expect(state.items[2].status, BatchItemStatus.ready);
    expect(state.currentIndex, 0);
    expect(state.items[0].draft, isNotNull);
  });

  test('save is blocked while uncertain fields are unchecked', () async {
    final (container, repository) =
        makeContainer([photo(1)], confidence: 0.5);
    final controller = container.read(batchImportProvider.notifier);

    await controller.addPhotos();
    controller.start();
    await pumpEventQueue();
    await controller.saveCurrent();

    var state = container.read(batchImportProvider);
    expect(repository.savedCount, 0);
    expect(state.failure, isA<ValidationFailure>());
    expect(state.items.single.status, BatchItemStatus.ready);

    controller.confirmField('hb');
    await controller.saveCurrent();

    state = container.read(batchImportProvider);
    expect(repository.savedCount, 1);
    expect(state.items.single.status, BatchItemStatus.saved);
    expect(state.phase, BatchPhase.summary);
  });

  test('skip and save advance through the queue to the summary', () async {
    final (container, repository) =
        makeContainer([photo(1), photo(2), photo(failMarker)]);
    final controller = container.read(batchImportProvider.notifier);

    await controller.addPhotos();
    controller.start();
    await pumpEventQueue();

    controller.skipCurrent();
    await controller.saveCurrent();
    // Only the failed item remains; moving past it ends the batch.
    controller.continueAfterFailure();
    await pumpEventQueue();

    final state = container.read(batchImportProvider);
    expect(state.phase, BatchPhase.summary);
    expect(state.skippedCount, 1);
    expect(state.savedCount, 1);
    expect(state.failedItems, hasLength(1));
    expect(repository.savedCount, 1);
  });

  test('retry re-queues a failed item and extracts it again', () async {
    final (container, repository) = makeContainer([photo(failMarker)]);
    final controller = container.read(batchImportProvider.notifier);

    await controller.addPhotos();
    controller.start();
    await pumpEventQueue();
    expect(container.read(batchImportProvider).items.single.status,
        BatchItemStatus.failed);

    controller.retry(container.read(batchImportProvider).items.single.id);
    await pumpEventQueue();

    expect(repository.extractedPageCounts, [1, 1]);
    expect(container.read(batchImportProvider).phase, BatchPhase.running);
  });

  test('combineSelected merges photos into one multi-page item', () async {
    final (container, repository) =
        makeContainer([photo(1), photo(2), photo(3)]);
    final controller = container.read(batchImportProvider.notifier);

    await controller.addPhotos();
    var state = container.read(batchImportProvider);
    controller.toggleSelect(state.items[0].id);
    controller.toggleSelect(state.items[2].id);
    controller.combineSelected();

    state = container.read(batchImportProvider);
    expect(state.items, hasLength(2));
    expect(state.items[0].combined, isTrue);
    expect(state.items[0].pages, hasLength(2));
    expect(state.items[0].pages[0].bytes.first, 1);
    expect(state.items[0].pages[1].bytes.first, 3);
    expect(state.selection, isEmpty);

    controller.start();
    await pumpEventQueue();
    expect(repository.extractedPageCounts, [2, 1]);

    controller.ungroup(state.items[0].id);
    // Ungrouping after start is a setup-screen action; here it just
    // verifies the split shape.
    final ungrouped = container.read(batchImportProvider);
    expect(ungrouped.items, hasLength(3));
    expect(ungrouped.items.every((i) => i.pages.length == 1), isTrue);
  });
}
