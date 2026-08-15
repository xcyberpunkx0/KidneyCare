import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/features/claims/presentation/controllers/claims_providers.dart';
import 'package:recora/shared/domain/claim_status.dart';

Claim _claim({
  required String id,
  required ClaimStatus status,
  DateTime? submittedOn,
  DateTime? settledOn,
  int? claimedPaise,
  int? approvedPaise,
}) {
  return Claim(
    id: id,
    policyId: null,
    title: id,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    submittedOn: submittedOn,
    settledOn: settledOn,
    claimedAmountPaise: claimedPaise,
    approvedAmountPaise: approvedPaise,
    insurerRef: '',
    note: '',
  );
}

void main() {
  final now = DateTime(2026, 8, 15);

  test('ytdTotals sums this year only', () {
    final claims = [
      _claim(
          id: 'a',
          status: ClaimStatus.submitted,
          submittedOn: DateTime(2026, 3, 1),
          claimedPaise: 1000000),
      _claim(
          id: 'b',
          status: ClaimStatus.approved,
          submittedOn: DateTime(2026, 4, 1),
          settledOn: DateTime(2026, 5, 1),
          claimedPaise: 2000000,
          approvedPaise: 1800000),
      _claim(
          id: 'old',
          status: ClaimStatus.approved,
          submittedOn: DateTime(2025, 4, 1),
          settledOn: DateTime(2025, 5, 1),
          claimedPaise: 999900,
          approvedPaise: 999900),
    ];
    final totals = ytdTotals(claims, now);
    expect(totals.claimedPaise, 3000000);
    expect(totals.recoveredPaise, 1800000);
  });

  test('staleSubmitted keeps only claims waiting longer than 30 days', () {
    final claims = [
      _claim(
          id: 'fresh',
          status: ClaimStatus.submitted,
          submittedOn: DateTime(2026, 8, 1)),
      _claim(
          id: 'stale',
          status: ClaimStatus.submitted,
          submittedOn: DateTime(2026, 6, 1)),
      _claim(id: 'draft', status: ClaimStatus.draft),
    ];
    expect(staleSubmitted(claims, now).map((c) => c.id), ['stale']);
  });
}
