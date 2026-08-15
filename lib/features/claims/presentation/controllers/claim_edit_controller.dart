import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository_impl/claims_repository_impl.dart';

class ClaimEditState {
  const ClaimEditState({
    required this.title,
    required this.selectedDocumentIds,
    this.policyId,
    this.error,
    this.saving = false,
  });

  final String title;
  final Set<String> selectedDocumentIds;
  final String? policyId;
  final String? error;
  final bool saving;

  ClaimEditState copyWith({
    String? title,
    Set<String>? selectedDocumentIds,
    String? policyId,
    String? error,
    bool? saving,
  }) {
    return ClaimEditState(
      title: title ?? this.title,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      policyId: policyId ?? this.policyId,
      error: error,
      saving: saving ?? this.saving,
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
