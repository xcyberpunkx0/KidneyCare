import 'package:drift/drift.dart';

import '../../../shared/domain/document_type.dart';
import '../app_database.dart';
import '../tables.dart';

part 'claim_dao.g.dart';

/// Data access for insurance claims: policies, claims, their attached
/// documents and checklists. Queries arrive with the claims feature.
@DriftAccessor(tables: [
  InsurancePolicies,
  Claims,
  ClaimDocuments,
  ClaimChecklistItems,
  Documents,
])
class ClaimDao extends DatabaseAccessor<AppDatabase> with _$ClaimDaoMixin {
  ClaimDao(super.db);

  Stream<List<Claim>> watchAllClaims() {
    final query = select(claims)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  Stream<Claim?> watchClaim(String id) {
    return (select(claims)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<Claim?> getClaimById(String id) {
    return (select(claims)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<Document>> watchDocumentsForClaim(String claimId) {
    final query = select(documents).join([
      innerJoin(
          claimDocuments, claimDocuments.documentId.equalsExp(documents.id)),
    ])
      ..where(claimDocuments.claimId.equals(claimId))
      ..orderBy([OrderingTerm.desc(documents.documentDate)]);
    return query.watch().map(
        (rows) => rows.map((row) => row.readTable(documents)).toList());
  }

  Future<List<Document>> getDocumentsForClaim(String claimId) async {
    final query = select(documents).join([
      innerJoin(
          claimDocuments, claimDocuments.documentId.equalsExp(documents.id)),
    ])
      ..where(claimDocuments.claimId.equals(claimId))
      ..orderBy([OrderingTerm.desc(documents.documentDate)]);
    final rows = await query.get();
    return rows.map((row) => row.readTable(documents)).toList();
  }

  Stream<List<ClaimDocument>> watchAllLinks() =>
      select(claimDocuments).watch();

  Future<int> countDocumentsForClaim(String claimId) async {
    final count = claimDocuments.documentId.count();
    final query = selectOnly(claimDocuments)
      ..addColumns([count])
      ..where(claimDocuments.claimId.equals(claimId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<List<ClaimChecklistItem>> watchChecklist(String claimId) {
    final query = select(claimChecklistItems)
      ..where((t) => t.claimId.equals(claimId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.watch();
  }

  /// Bills that belong to no claim, oldest first — the ones whose
  /// submission window is running out soonest.
  Stream<List<Document>> watchUnclaimedBills() {
    final query = select(documents)
      ..where((d) =>
          d.type.equalsValue(DocumentType.bill) &
          notExistsQuery(select(claimDocuments)
            ..where((cd) => cd.documentId.equalsExp(d.id))))
      ..orderBy([(d) => OrderingTerm.asc(d.documentDate)]);
    return query.watch();
  }

  Stream<List<InsurancePolicy>> watchPolicies() =>
      (select(insurancePolicies)
            ..orderBy([(t) => OrderingTerm.asc(t.insurerName)]))
          .watch();

  Future<void> upsertClaim(ClaimsCompanion entry) =>
      into(claims).insertOnConflictUpdate(entry);

  Future<void> deleteClaimCascade(String id) {
    return transaction(() async {
      await (delete(claimChecklistItems)..where((t) => t.claimId.equals(id)))
          .go();
      await (delete(claimDocuments)..where((t) => t.claimId.equals(id))).go();
      await (delete(claims)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> attachDocument(String claimId, String documentId) {
    return into(claimDocuments).insert(
      ClaimDocumentsCompanion(
        claimId: Value(claimId),
        documentId: Value(documentId),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> detachDocument(String claimId, String documentId) {
    return (delete(claimDocuments)
          ..where((t) =>
              t.claimId.equals(claimId) & t.documentId.equals(documentId)))
        .go();
  }

  Future<void> upsertChecklistItem(ClaimChecklistItemsCompanion entry) =>
      into(claimChecklistItems).insertOnConflictUpdate(entry);

  Future<void> deleteChecklistItem(String id) =>
      (delete(claimChecklistItems)..where((t) => t.id.equals(id))).go();

  Future<void> upsertPolicy(InsurancePoliciesCompanion entry) =>
      into(insurancePolicies).insertOnConflictUpdate(entry);

  Future<void> deletePolicy(String id) {
    return transaction(() async {
      await (update(claims)..where((c) => c.policyId.equals(id)))
          .write(const ClaimsCompanion(policyId: Value(null)));
      await (delete(insurancePolicies)..where((t) => t.id.equals(id))).go();
    });
  }
}
