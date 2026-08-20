import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recora/core/services/photo_picker.dart';
import 'package:recora/core/services/scan_page.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/core/utils/result.dart';
import 'package:recora/features/capture/data/repository_impl/capture_repository_impl.dart';
import 'package:recora/features/capture/domain/entities/extraction.dart';
import 'package:recora/features/capture/domain/repositories/capture_repository.dart';
import 'package:recora/features/capture/presentation/controllers/batch_import_controller.dart';
import 'package:recora/features/capture/presentation/pages/batch_import_page.dart';
import 'package:recora/l10n/app_localizations.dart';
import 'package:recora/shared/domain/document_type.dart';

ExtractionResult _extraction() {
  return ExtractionResult(
    documentType: DocumentType.labReport,
    title: 'Panel',
    hospital: '',
    doctor: '',
    documentDate: DateTime(2026, 8, 10),
    fields: const [
      ExtractedField(
        key: 'hb',
        label: 'HB',
        value: '9.4',
        confidence: 0.95,
      ),
    ],
  );
}

/// Extraction stays pending until the test releases it, so the waiting
/// state is observable.
class _GatedRepository implements CaptureRepository {
  final _gates = <Completer<void>>[];

  void releaseNext() => _gates.removeAt(0).complete();

  @override
  Future<Result<ExtractionResult>> extract(List<ScanPage> pages) async {
    final gate = Completer<void>();
    _gates.add(gate);
    await gate.future;
    return Result.ok(_extraction());
  }

  @override
  Future<Result<String>> saveReviewed({
    required List<ScanPage> pages,
    required ExtractionResult reviewed,
  }) async {
    return const Result.ok('doc-1');
  }
}

class _FakePhotoPicker extends PhotoPicker {
  _FakePhotoPicker(this.photos) : super(ImagePicker());

  final List<Uint8List> photos;

  @override
  Future<List<Uint8List>> pickManyFromGallery() async => photos;
}

void main() {
  testWidgets('review queue: waiting state, then header and Save & next',
      (tester) async {
    final repository = _GatedRepository();
    final container = ProviderContainer(overrides: [
      captureRepositoryProvider.overrideWithValue(repository),
      photoPickerProvider.overrideWithValue(_FakePhotoPicker([
        Uint8List.fromList([1]),
        Uint8List.fromList([2]),
      ])),
    ]);
    addTearDown(container.dispose);
    container.listen(batchImportProvider, (_, _) {});

    final controller = container.read(batchImportProvider.notifier);
    await controller.addPhotos();
    controller.start();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BatchImportPage(),
      ),
    ));

    expect(find.text('Reading this document…'), findsOneWidget);
    expect(find.text('Reviewing 1 of 2'), findsOneWidget);

    repository.releaseNext();
    await tester.pumpAndSettle();

    expect(find.text('Reviewing 1 of 2'), findsOneWidget);
    expect(find.text('Save & next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Reading this document…'), findsNothing);

    await tester.tap(find.text('Save & next'));
    // Two pumps: one for the save future, one for the rebuild. Not
    // pumpAndSettle — the waiting spinner animates forever.
    await tester.pump();
    await tester.pump();
    // Item 2 is still behind its gate, so the queue shows the waiting
    // state for it.
    expect(find.text('Reviewing 2 of 2'), findsOneWidget);
    expect(find.text('Reading this document…'), findsOneWidget);

    repository.releaseNext();
    await tester.pumpAndSettle();
    expect(find.text('Save & next'), findsOneWidget);
  });
}
