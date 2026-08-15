import 'package:drift/drift.dart';

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
}
