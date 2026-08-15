import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';
import '../../../../shared/domain/timeline_event_type.dart';
import '../../domain/repositories/claims_repository.dart';

class ClaimsRepositoryImpl implements ClaimsRepository {
  ClaimsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _uuid = Uuid();

  @override
  Stream<List<Claim>> watchClaims() => _db.claimDao.watchAllClaims();

  @override
  Stream<Claim?> watchClaim(String id) => _db.claimDao.watchClaim(id);

  @override
  Stream<List<Document>> watchClaimDocuments(String claimId) =>
      _db.claimDao.watchDocumentsForClaim(claimId);

  @override
  Stream<List<ClaimDocument>> watchAllLinks() =>
      _db.claimDao.watchAllLinks();

  @override
  Stream<List<ClaimChecklistItem>> watchChecklist(String claimId) =>
      _db.claimDao.watchChecklist(claimId);

  @override
  Stream<List<Document>> watchUnclaimedBills() =>
      _db.claimDao.watchUnclaimedBills();

  @override
  Stream<List<InsurancePolicy>> watchPolicies() =>
      _db.claimDao.watchPolicies();

  @override
  Future<Result<String>> createClaim({
    required String title,
    required String? policyId,
    required List<String> documentIds,
    required List<String> checklistLabels,
  }) {
    return Result.guard(() async {
      final id = _uuid.v4();
      await _db.transaction(() async {
        await _db.claimDao.upsertClaim(ClaimsCompanion(
          id: Value(id),
          policyId: Value(policyId),
          title: Value(title),
          status: const Value(ClaimStatus.draft),
          createdAt: Value(DateTime.now()),
        ));
        for (final documentId in documentIds) {
          await _db.claimDao.attachDocument(id, documentId);
        }
        for (final (index, label) in checklistLabels.indexed) {
          await _db.claimDao
              .upsertChecklistItem(ClaimChecklistItemsCompanion(
            id: Value(_uuid.v4()),
            claimId: Value(id),
            label: Value(label),
            sortOrder: Value(index),
          ));
        }
      });
      return id;
    });
  }

  @override
  Future<Result<void>> updateDraft({
    required String claimId,
    required String title,
    required String? policyId,
    required List<String> documentIds,
  }) {
    return Result.guard(() async {
      final claim = await _requireClaim(claimId);
      if (claim.status != ClaimStatus.draft) {
        throw const ValidationFailure(
            message: 'Only draft claims can be edited.');
      }
      await _db.transaction(() async {
        await _db.claimDao.upsertClaim(claim
            .toCompanion(true)
            .copyWith(title: Value(title), policyId: Value(policyId)));
        // One-shot read: a stream query would not emit until this
        // transaction commits, deadlocking the transaction on itself.
        final current =
            await _db.claimDao.getDocumentsForClaim(claimId);
        for (final doc in current) {
          if (!documentIds.contains(doc.id)) {
            await _db.claimDao.detachDocument(claimId, doc.id);
          }
        }
        for (final documentId in documentIds) {
          await _db.claimDao.attachDocument(claimId, documentId);
        }
      });
    });
  }

  @override
  Future<Result<void>> markSubmitted({
    required String claimId,
    required DateTime submittedOn,
    required int claimedAmountPaise,
    required String insurerRef,
  }) {
    return Result.guard(() async {
      final claim = await _requireClaim(claimId);
      if (!claim.status.canTransitionTo(ClaimStatus.submitted)) {
        throw const ValidationFailure(
            message: 'Only a draft claim can be submitted.');
      }
      final docCount =
          await _db.claimDao.countDocumentsForClaim(claimId);
      if (docCount == 0) {
        throw const ValidationFailure(
            message: 'Attach at least one document before submitting.');
      }
      await _db.transaction(() async {
        await _db.claimDao.upsertClaim(claim.toCompanion(true).copyWith(
              status: const Value(ClaimStatus.submitted),
              submittedOn: Value(submittedOn),
              claimedAmountPaise: Value(claimedAmountPaise),
              insurerRef: Value(insurerRef),
            ));
        await _timeline(
          title: 'Claim submitted · ${formatPaise(claimedAmountPaise)}',
          subtitle: claim.title,
          occurredAt: submittedOn,
        );
      });
    });
  }

  @override
  Future<Result<void>> recordOutcome({
    required String claimId,
    required ClaimStatus outcome,
    required DateTime settledOn,
    int? approvedAmountPaise,
  }) {
    return Result.guard(() async {
      final claim = await _requireClaim(claimId);
      if (!outcome.isOutcome ||
          !claim.status.canTransitionTo(outcome)) {
        throw const ValidationFailure(
            message: 'Only a submitted claim can be settled or rejected.');
      }
      await _db.transaction(() async {
        await _db.claimDao.upsertClaim(claim.toCompanion(true).copyWith(
              status: Value(outcome),
              settledOn: Value(settledOn),
              approvedAmountPaise: Value(approvedAmountPaise),
            ));
        final label = switch (outcome) {
          ClaimStatus.approved => 'Claim approved',
          ClaimStatus.partiallySettled => 'Claim partially settled',
          _ => 'Claim rejected',
        };
        final amount = approvedAmountPaise == null
            ? ''
            : ' · ${formatPaise(approvedAmountPaise)}';
        await _timeline(
          title: '$label$amount',
          subtitle: claim.title,
          occurredAt: settledOn,
        );
      });
    });
  }

  @override
  Future<Result<void>> reopenAsDraft(String claimId) {
    return Result.guard(() async {
      final claim = await _requireClaim(claimId);
      if (!claim.status.canTransitionTo(ClaimStatus.draft)) {
        throw const ValidationFailure(
            message: 'Only a rejected claim can be reopened.');
      }
      await _db.transaction(() async {
        await _db.claimDao.upsertClaim(ClaimsCompanion(
          id: Value(claim.id),
          policyId: Value(claim.policyId),
          title: Value(claim.title),
          status: const Value(ClaimStatus.draft),
          createdAt: Value(claim.createdAt),
          submittedOn: const Value(null),
          settledOn: const Value(null),
          claimedAmountPaise: const Value(null),
          approvedAmountPaise: const Value(null),
          insurerRef: const Value(''),
          note: Value(claim.note),
        ));
        await _timeline(
          title: 'Claim reopened',
          subtitle: claim.title,
          occurredAt: DateTime.now(),
        );
      });
    });
  }

  @override
  Future<Result<void>> setChecklistItemDone(String itemId, String claimId,
      String label, int sortOrder, bool isDone) {
    return Result.guard(() {
      return _db.claimDao.upsertChecklistItem(ClaimChecklistItemsCompanion(
        id: Value(itemId),
        claimId: Value(claimId),
        label: Value(label),
        sortOrder: Value(sortOrder),
        isDone: Value(isDone),
      ));
    });
  }

  @override
  Future<Result<void>> addChecklistItem(String claimId, String label) {
    return Result.guard(() async {
      final items = await _db.claimDao.getChecklist(claimId);
      final sortOrder = items.isEmpty
          ? 0
          : items.map((i) => i.sortOrder).reduce(max) + 1;
      await _db.claimDao.upsertChecklistItem(ClaimChecklistItemsCompanion(
        id: Value(_uuid.v4()),
        claimId: Value(claimId),
        label: Value(label),
        sortOrder: Value(sortOrder),
      ));
    });
  }

  @override
  Future<Result<void>> removeChecklistItem(String itemId) {
    return Result.guard(() => _db.claimDao.deleteChecklistItem(itemId));
  }

  @override
  Future<Result<void>> deleteClaim(String claimId) {
    return Result.guard(() => _db.claimDao.deleteClaimCascade(claimId));
  }

  @override
  Future<Result<void>> savePolicy({
    required String? id,
    required String insurerName,
    required String policyNumber,
    required String tpaName,
    required int claimWindowDays,
  }) {
    return Result.guard(() {
      return _db.claimDao.upsertPolicy(InsurancePoliciesCompanion(
        id: Value(id ?? _uuid.v4()),
        insurerName: Value(insurerName),
        policyNumber: Value(policyNumber),
        tpaName: Value(tpaName),
        claimWindowDays: Value(claimWindowDays),
      ));
    });
  }

  Future<Claim> _requireClaim(String id) async {
    final claim = await _db.claimDao.getClaimById(id);
    if (claim == null) {
      throw const StorageFailure(message: 'This claim no longer exists.');
    }
    return claim;
  }

  Future<void> _timeline({
    required String title,
    required String subtitle,
    required DateTime occurredAt,
  }) {
    return _db.timelineDao.insert(TimelineEventsCompanion(
      id: Value(_uuid.v4()),
      type: const Value(TimelineEventType.claim),
      title: Value(title),
      subtitle: Value(subtitle),
      occurredAt: Value(occurredAt),
    ));
  }
}

final claimsRepositoryProvider = Provider<ClaimsRepository>((ref) {
  return ClaimsRepositoryImpl(ref.watch(databaseProvider));
});
