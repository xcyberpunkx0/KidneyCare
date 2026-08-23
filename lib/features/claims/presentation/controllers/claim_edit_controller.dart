import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/pdf_import.dart';
import '../../../../core/services/photo_picker.dart';
import '../../../../core/services/scan_page.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../shared/domain/document_type.dart';
import '../../../capture/data/repository_impl/capture_repository_impl.dart';
import '../../data/repository_impl/claims_repository_impl.dart';

class ClaimEditState {
  const ClaimEditState({
    required this.title,
    required this.selectedDocumentIds,
    this.policyId,
    this.error,
    this.saving = false,
    this.importing = false,
  });

  final String title;
  final Set<String> selectedDocumentIds;
  final String? policyId;
  final String? error;
  final bool saving;
  final bool importing;

  ClaimEditState copyWith({
    String? title,
    Set<String>? selectedDocumentIds,
    String? policyId,
    String? error,
    bool? saving,
    bool? importing,
  }) {
    return ClaimEditState(
      title: title ?? this.title,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      policyId: policyId ?? this.policyId,
      error: error,
      saving: saving ?? this.saving,
      importing: importing ?? this.importing,
    );
  }

  ClaimEditState withToggled(String id) {
    final ids = Set<String>.from(selectedDocumentIds);
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    return copyWith(selectedDocumentIds: ids);
  }
}

/// Drives the new/edit-claim form. Pure state moves are static or on the
/// state class so they unit-test without a container.
class ClaimEditController extends Notifier<ClaimEditState> {
  @override
  ClaimEditState build() =>
      const ClaimEditState(title: '', selectedDocumentIds: {});

  static bool validateTitle(String title) => title.trim().isNotEmpty;

  void setTitle(String title) => state = state.copyWith(title: title);

  void setPolicy(String? policyId) =>
      state = state.copyWith(policyId: policyId);

  void toggleDocument(String id) => state = state.withToggled(id);

  void preselect(Set<String> ids, String title, String? policyId) =>
      state = ClaimEditState(
          title: title, selectedDocumentIds: ids, policyId: policyId);

  /// Imports gallery photos into the vault as bill documents and selects
  /// them on this claim. [defaultTitle] names them — photos carry no
  /// filename.
  Future<void> importPhotosFromDevice({required String defaultTitle}) async {
    state = state.copyWith(importing: true);
    try {
      final photos =
          await ref.read(photoPickerProvider).pickManyFromGallery();
      for (final bytes in photos) {
        await _saveAsBill(pages: [ScanPage.jpeg(bytes)], title: defaultTitle);
      }
    } on AppFailure catch (failure) {
      state = state.copyWith(error: failure.message);
    } finally {
      state = state.copyWith(importing: false);
    }
  }

  /// Imports PDFs from the system file browser into the vault as bill
  /// documents (one document per file, named after it) and selects them.
  Future<void> importPdfsFromDevice() async {
    state = state.copyWith(importing: true);
    try {
      final pdfImport = ref.read(pdfImportProvider);
      final pdfs = await pdfImport.pickPdfs();
      for (final pdf in pdfs) {
        // One unreadable file must not sink the rest of the batch.
        try {
          final pages = await pdfImport.rasterize(pdf);
          await _saveAsBill(
            pages: pages,
            title: pdf.name.replaceFirst(
                RegExp(r'\.pdf$', caseSensitive: false), ''),
          );
        } on AppFailure catch (failure) {
          state = state.copyWith(error: failure.message);
        }
      }
    } on AppFailure catch (failure) {
      state = state.copyWith(error: failure.message);
    } finally {
      state = state.copyWith(importing: false);
    }
  }

  Future<void> _saveAsBill({
    required List<ScanPage> pages,
    required String title,
  }) async {
    final result = await ref.read(captureRepositoryProvider).saveManual(
          pages: pages,
          type: DocumentType.bill,
          title: title,
          documentDate: DateTime.now(),
        );
    result.when(
      ok: (id) => state = state.copyWith(
          selectedDocumentIds: {...state.selectedDocumentIds, id}),
      err: (failure) => state = state.copyWith(error: failure.message),
    );
  }

  /// Creates or updates the draft. Returns true on success; on failure the
  /// state carries a user-presentable error.
  Future<bool> save({
    required String? claimId,
    required String emptyTitleMessage,
    required List<String> checklistLabels,
  }) async {
    if (!validateTitle(state.title)) {
      state = state.copyWith(error: emptyTitleMessage);
      return false;
    }
    state = state.copyWith(saving: true);
    final repo = ref.read(claimsRepositoryProvider);
    final result = claimId == null
        ? await repo.createClaim(
            title: state.title.trim(),
            policyId: state.policyId,
            documentIds: state.selectedDocumentIds.toList(),
            checklistLabels: checklistLabels,
          )
        : await repo.updateDraft(
            claimId: claimId,
            title: state.title.trim(),
            policyId: state.policyId,
            documentIds: state.selectedDocumentIds.toList(),
          );
    return result.when(
      ok: (_) => true,
      err: (failure) {
        state = state.copyWith(error: failure.message, saving: false);
        return false;
      },
    );
  }
}

final claimEditControllerProvider =
    NotifierProvider.autoDispose<ClaimEditController, ClaimEditState>(
  ClaimEditController.new,
);
