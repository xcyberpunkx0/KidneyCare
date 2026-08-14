
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/photo_picker.dart';
import '../../../../core/utils/app_failure.dart';
import '../../data/repository_impl/capture_repository_impl.dart';
import '../../domain/entities/extraction.dart';

enum CaptureStep { camera, cropping, extracting, review, saving, saved }

/// Immutable state of the capture flow.
@immutable
class CaptureFlowState {
  const CaptureFlowState({
    this.step = CaptureStep.camera,
    this.pickedBytes,
    this.croppedBytes,
    this.extraction,
    this.editedValues = const {},
    this.verifiedKeys = const {},
    this.failure,
  });

  final CaptureStep step;
  final Uint8List? pickedBytes;
  final Uint8List? croppedBytes;
  final ExtractionResult? extraction;

  /// Caregiver edits, keyed by field key.
  final Map<String, String> editedValues;

  /// Low/medium-confidence fields the caregiver has confirmed.
  final Set<String> verifiedKeys;

  final AppFailure? failure;

  /// Fields with caregiver edits applied.
  List<ExtractedField> get reviewFields => [
        for (final field in extraction?.fields ?? const <ExtractedField>[])
          field.copyWith(value: editedValues[field.key]),
      ];

  /// A field counts as checked when confidence is high, it was edited, or
  /// it was explicitly confirmed.
  bool isChecked(ExtractedField field) =>
      !field.requiresVerification ||
      verifiedKeys.contains(field.key) ||
      editedValues.containsKey(field.key);

  int get uncheckedCount =>
      reviewFields.where((f) => !isChecked(f)).length;

  bool get allChecked => uncheckedCount == 0;

  CaptureFlowState copyWith({
    CaptureStep? step,
    Uint8List? pickedBytes,
    Uint8List? croppedBytes,
    ExtractionResult? extraction,
    Map<String, String>? editedValues,
    Set<String>? verifiedKeys,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return CaptureFlowState(
      step: step ?? this.step,
      pickedBytes: pickedBytes ?? this.pickedBytes,
      croppedBytes: croppedBytes ?? this.croppedBytes,
      extraction: extraction ?? this.extraction,
      editedValues: editedValues ?? this.editedValues,
      verifiedKeys: verifiedKeys ?? this.verifiedKeys,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

/// Drives the capture flow: camera → crop → extract → review → save.
class CaptureFlowController extends Notifier<CaptureFlowState> {
  @override
  CaptureFlowState build() => const CaptureFlowState();

  Future<void> takePhoto() => _pick(camera: true);

  Future<void> pickFromGallery() => _pick(camera: false);

  Future<void> _pick({required bool camera}) async {
    final picker = ref.read(photoPickerProvider);
    try {
      final bytes =
          camera ? await picker.takePhoto() : await picker.pickFromGallery();
      if (bytes == null) return;
      state = state.copyWith(
        step: CaptureStep.cropping,
        pickedBytes: bytes,
        clearFailure: true,
      );
    } on AppFailure catch (failure) {
      state = state.copyWith(failure: failure);
    }
  }

  void retake() {
    state = const CaptureFlowState();
  }

  Future<void> confirmCrop(Uint8List croppedBytes) async {
    state = state.copyWith(
      step: CaptureStep.extracting,
      croppedBytes: croppedBytes,
      clearFailure: true,
    );
    final result =
        await ref.read(captureRepositoryProvider).extract(croppedBytes);
    result.when(
      ok: (extraction) {
        state = state.copyWith(
          step: CaptureStep.review,
          extraction: extraction,
          editedValues: const {},
          verifiedKeys: const {},
        );
      },
      err: (failure) {
        state = state.copyWith(step: CaptureStep.cropping, failure: failure);
      },
    );
  }

  void editField(String key, String value) {
    state = state.copyWith(
      editedValues: {...state.editedValues, key: value},
    );
  }

  void confirmField(String key) {
    state = state.copyWith(verifiedKeys: {...state.verifiedKeys, key});
  }

  void chooseAlternative(String key, String value) {
    state = state.copyWith(
      editedValues: {...state.editedValues, key: value},
      verifiedKeys: {...state.verifiedKeys, key},
    );
  }

  /// Validates, persists, and reports success via [CaptureStep.saved].
  Future<void> save() async {
    final extraction = state.extraction;
    final bytes = state.croppedBytes;
    if (extraction == null || bytes == null) return;
    if (!state.allChecked) {
      state = state.copyWith(
        failure: ValidationFailure(
          message: '${state.uncheckedCount} field(s) still need a check '
              'before saving.',
        ),
      );
      return;
    }

    state = state.copyWith(step: CaptureStep.saving, clearFailure: true);
    final reviewed = ExtractionResult(
      documentType: extraction.documentType,
      title: extraction.title,
      hospital: extraction.hospital,
      doctor: extraction.doctor,
      documentDate: extraction.documentDate,
      fields: state.reviewFields,
      medicines: extraction.medicines,
      labValues: extraction.labValues,
      tags: extraction.tags,
      ocrText: extraction.ocrText,
    );
    final result = await ref
        .read(captureRepositoryProvider)
        .saveReviewed(originalBytes: bytes, reviewed: reviewed);
    result.when(
      ok: (_) => state = state.copyWith(step: CaptureStep.saved),
      err: (failure) => state =
          state.copyWith(step: CaptureStep.review, failure: failure),
    );
  }

  void dismissFailure() {
    state = state.copyWith(clearFailure: true);
  }
}

final captureFlowProvider = NotifierProvider.autoDispose<
    CaptureFlowController, CaptureFlowState>(CaptureFlowController.new);
