import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/utils/app_failure.dart';
import 'package:recora/features/claims/data/repository_impl/claims_repository_impl.dart';
import 'package:recora/shared/domain/claim_status.dart';
import 'package:recora/shared/domain/document_type.dart';
import 'package:recora/shared/domain/timeline_event_type.dart';

void main() {
  late AppDatabase db;
  late ClaimsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ClaimsRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> addBill(String id) {
    return db.documentDao.upsert(DocumentsCompanion(
      id: Value(id),
      type: const Value(DocumentType.bill),
      title: Value('Bill $id'),
      documentDate: Value(DateTime(2026, 8, 1)),
      capturedAt: Value(DateTime(2026, 8, 1)),
    ));
  }

  test('createClaim seeds checklist and attaches documents', () async {
    await addBill('b1');
    final result = await repo.createClaim(
      title: 'August bundle',
      policyId: null,
      documentIds: ['b1'],
      checklistLabels: ['Claim form', 'Original bills'],
    );
    expect(result.isOk, isTrue);
    final id = result.valueOrNull!;
    final checklist = await db.claimDao.watchChecklist(id).first;
    expect(checklist.map((i) => i.label), ['Claim form', 'Original bills']);
    expect(await db.claimDao.countDocumentsForClaim(id), 1);
  });

  test('markSubmitted refuses a documentless draft', () async {
    final created = await repo.createClaim(
      title: 'Empty',
      policyId: null,
      documentIds: [],
      checklistLabels: [],
    );
    final result = await repo.markSubmitted(
      claimId: created.valueOrNull!,
      submittedOn: DateTime(2026, 8, 15),
      claimedAmountPaise: 1000000,
      insurerRef: '',
    );
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('submit then outcome walks the lifecycle and writes timeline events',
      () async {
    await addBill('b1');
    final id = (await repo.createClaim(
      title: 'August bundle',
      policyId: null,
      documentIds: ['b1'],
      checklistLabels: [],
    ))
        .valueOrNull!;

    final submitted = await repo.markSubmitted(
      claimId: id,
      submittedOn: DateTime(2026, 8, 15),
      claimedAmountPaise: 1240000,
      insurerRef: 'TPA-123',
    );
    expect(submitted.isOk, isTrue);
    expect((await db.claimDao.getClaimById(id))!.status,
        ClaimStatus.submitted);

    final settled = await repo.recordOutcome(
      claimId: id,
      outcome: ClaimStatus.partiallySettled,
      settledOn: DateTime(2026, 9, 2),
      approvedAmountPaise: 1110000,
    );
    expect(settled.isOk, isTrue);
    final claim = (await db.claimDao.getClaimById(id))!;
    expect(claim.status, ClaimStatus.partiallySettled);
    expect(claim.approvedAmountPaise, 1110000);

    final events = await db.timelineDao.getPage(limit: 10, offset: 0);
    final claimEvents =
        events.where((e) => e.type == TimelineEventType.claim).toList();
    expect(claimEvents, hasLength(2));
    expect(claimEvents.map((e) => e.title),
        everyElement(contains('Claim')));
  });

  test('recordOutcome refuses illegal transitions', () async {
    await addBill('b1');
    final id = (await repo.createClaim(
      title: 'Draft only',
      policyId: null,
      documentIds: ['b1'],
      checklistLabels: [],
    ))
        .valueOrNull!;
    final result = await repo.recordOutcome(
      claimId: id,
      outcome: ClaimStatus.approved,
      settledOn: DateTime(2026, 9, 2),
      approvedAmountPaise: 100,
    );
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('reopenAsDraft resets a rejected claim', () async {
    await addBill('b1');
    final id = (await repo.createClaim(
      title: 'Bundle',
      policyId: null,
      documentIds: ['b1'],
      checklistLabels: [],
    ))
        .valueOrNull!;
    await repo.markSubmitted(
      claimId: id,
      submittedOn: DateTime(2026, 8, 15),
      claimedAmountPaise: 500000,
      insurerRef: '',
    );
    await repo.recordOutcome(
      claimId: id,
      outcome: ClaimStatus.rejected,
      settledOn: DateTime(2026, 9, 1),
    );

    final reopened = await repo.reopenAsDraft(id);
    expect(reopened.isOk, isTrue);
    final claim = (await db.claimDao.getClaimById(id))!;
    expect(claim.status, ClaimStatus.draft);
    expect(claim.submittedOn, isNull);
    expect(claim.settledOn, isNull);
    expect(claim.claimedAmountPaise, isNull);
    expect(claim.approvedAmountPaise, isNull);
  });
}
