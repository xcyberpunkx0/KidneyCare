import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/claim_status.dart';

/// Vault-backed store of insurance reimbursement claims.
///
/// Enforces the claim lifecycle: draft → submitted → outcome, with
/// rejected claims reopenable as drafts. All writes are transactional
/// and status changes append to the medical timeline.
abstract interface class ClaimsRepository {
  Stream<List<Claim>> watchClaims();
  Stream<Claim?> watchClaim(String id);
  Stream<List<Document>> watchClaimDocuments(String claimId);
  Stream<List<ClaimDocument>> watchAllLinks();
  Stream<List<ClaimChecklistItem>> watchChecklist(String claimId);
  Stream<List<Document>> watchUnclaimedBills();
  Stream<List<InsurancePolicy>> watchPolicies();
  Future<Result<String>> createClaim({
    required String title,
    required String? policyId,
    required List<String> documentIds,
    required List<String> checklistLabels,
  });
  Future<Result<void>> updateDraft({
    required String claimId,
    required String title,
    required String? policyId,
    required List<String> documentIds,
  });
  Future<Result<void>> markSubmitted({
    required String claimId,
    required DateTime submittedOn,
    required int claimedAmountPaise,
    required String insurerRef,
  });
  Future<Result<void>> recordOutcome({
    required String claimId,
    required ClaimStatus outcome,
    required DateTime settledOn,
    int? approvedAmountPaise,
  });
  Future<Result<void>> reopenAsDraft(String claimId);
  Future<Result<void>> setChecklistItemDone(String itemId, String claimId,
      String label, int sortOrder, bool isDone);
  Future<Result<void>> addChecklistItem(String claimId, String label);
  Future<Result<void>> removeChecklistItem(String itemId);
  Future<Result<void>> deleteClaim(String claimId);
  Future<Result<void>> savePolicy({
    required String? id,
    required String insurerName,
    required String policyNumber,
    required String tpaName,
    required int claimWindowDays,
  });
}
