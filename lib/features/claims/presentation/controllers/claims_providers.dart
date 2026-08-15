import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../shared/domain/claim_status.dart';
import '../../data/repository_impl/claims_repository_impl.dart';

final claimsListProvider = StreamProvider.autoDispose<List<Claim>>((ref) {
  return ref.watch(claimsRepositoryProvider).watchClaims();
});

final claimLinksProvider =
    StreamProvider.autoDispose<List<ClaimDocument>>((ref) {
  return ref.watch(claimsRepositoryProvider).watchAllLinks();
});

final unclaimedBillsProvider =
    StreamProvider.autoDispose<List<Document>>((ref) {
  return ref.watch(claimsRepositoryProvider).watchUnclaimedBills();
});

final policiesProvider =
    StreamProvider.autoDispose<List<InsurancePolicy>>((ref) {
  return ref.watch(claimsRepositoryProvider).watchPolicies();
});

final claimProvider =
    StreamProvider.autoDispose.family<Claim?, String>((ref, id) {
  return ref.watch(claimsRepositoryProvider).watchClaim(id);
});

final claimDocumentsProvider =
    StreamProvider.autoDispose.family<List<Document>, String>((ref, id) {
  return ref.watch(claimsRepositoryProvider).watchClaimDocuments(id);
});

final claimChecklistProvider = StreamProvider.autoDispose
    .family<List<ClaimChecklistItem>, String>((ref, id) {
  return ref.watch(claimsRepositoryProvider).watchChecklist(id);
});

/// Money claimed (by submission date) and recovered (by settlement date)
/// in [now]'s calendar year.
({int claimedPaise, int recoveredPaise}) ytdTotals(
    List<Claim> claims, DateTime now) {
  var claimed = 0;
  var recovered = 0;
  for (final claim in claims) {
    if (claim.submittedOn?.year == now.year) {
      claimed += claim.claimedAmountPaise ?? 0;
    }
    if (claim.settledOn?.year == now.year) {
      recovered += claim.approvedAmountPaise ?? 0;
    }
  }
  return (claimedPaise: claimed, recoveredPaise: recovered);
}

/// Submitted claims that have waited more than 30 days for a decision —
/// worth a follow-up call.
List<Claim> staleSubmitted(List<Claim> claims, DateTime now) {
  return claims
      .where((c) =>
          c.status == ClaimStatus.submitted &&
          c.submittedOn != null &&
          now.difference(c.submittedOn!).inDays > 30)
      .toList();
}
