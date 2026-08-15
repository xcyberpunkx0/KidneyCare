// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_dao.dart';

// ignore_for_file: type=lint
mixin _$ClaimDaoMixin on DatabaseAccessor<AppDatabase> {
  $InsurancePoliciesTable get insurancePolicies =>
      attachedDatabase.insurancePolicies;
  $ClaimsTable get claims => attachedDatabase.claims;
  $ClaimDocumentsTable get claimDocuments => attachedDatabase.claimDocuments;
  $ClaimChecklistItemsTable get claimChecklistItems =>
      attachedDatabase.claimChecklistItems;
  $DocumentsTable get documents => attachedDatabase.documents;
  ClaimDaoManager get managers => ClaimDaoManager(this);
}

class ClaimDaoManager {
  final _$ClaimDaoMixin _db;
  ClaimDaoManager(this._db);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(
        _db.attachedDatabase,
        _db.insurancePolicies,
      );
  $$ClaimsTableTableManager get claims =>
      $$ClaimsTableTableManager(_db.attachedDatabase, _db.claims);
  $$ClaimDocumentsTableTableManager get claimDocuments =>
      $$ClaimDocumentsTableTableManager(
        _db.attachedDatabase,
        _db.claimDocuments,
      );
  $$ClaimChecklistItemsTableTableManager get claimChecklistItems =>
      $$ClaimChecklistItemsTableTableManager(
        _db.attachedDatabase,
        _db.claimChecklistItems,
      );
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db.attachedDatabase, _db.documents);
}
