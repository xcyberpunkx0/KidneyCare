import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/shared/domain/claim_status.dart';
import 'package:recora/shared/domain/document_type.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addDocument(String id, DocumentType type, DateTime date) {
    return db.documentDao.upsert(DocumentsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value('Doc $id'),
      documentDate: Value(date),
      capturedAt: Value(date),
    ));
  }

  Future<void> addClaim(String id) {
    return db.claimDao.upsertClaim(ClaimsCompanion(
      id: Value(id),
      title: Value('Claim $id'),
      status: const Value(ClaimStatus.draft),
      createdAt: Value(DateTime(2026, 8, 1)),
    ));
  }

  test('unclaimed bills = bills without a junction row, oldest first',
      () async {
    await addDocument('b1', DocumentType.bill, DateTime(2026, 8, 10));
    await addDocument('b2', DocumentType.bill, DateTime(2026, 8, 1));
    await addDocument('r1', DocumentType.labReport, DateTime(2026, 8, 5));
    await addClaim('c1');
    await db.claimDao.attachDocument('c1', 'b1');

    final unclaimed = await db.claimDao.watchUnclaimedBills().first;
    expect(unclaimed.map((d) => d.id), ['b2']);
  });

  test('detach makes a bill unclaimed again', () async {
    await addDocument('b1', DocumentType.bill, DateTime(2026, 8, 10));
    await addClaim('c1');
    await db.claimDao.attachDocument('c1', 'b1');
    await db.claimDao.detachDocument('c1', 'b1');

    final unclaimed = await db.claimDao.watchUnclaimedBills().first;
    expect(unclaimed.map((d) => d.id), ['b1']);
  });

  test('attach is idempotent and countDocumentsForClaim counts', () async {
    await addDocument('b1', DocumentType.bill, DateTime(2026, 8, 10));
    await addClaim('c1');
    await db.claimDao.attachDocument('c1', 'b1');
    await db.claimDao.attachDocument('c1', 'b1');
    expect(await db.claimDao.countDocumentsForClaim('c1'), 1);
  });

  test('deleteClaimCascade removes links and checklist, keeps documents',
      () async {
    await addDocument('b1', DocumentType.bill, DateTime(2026, 8, 10));
    await addClaim('c1');
    await db.claimDao.attachDocument('c1', 'b1');
    await db.claimDao.upsertChecklistItem(ClaimChecklistItemsCompanion(
      id: const Value('i1'),
      claimId: const Value('c1'),
      label: const Value('Claim form'),
    ));

    await db.claimDao.deleteClaimCascade('c1');

    expect(await db.claimDao.getClaimById('c1'), isNull);
    expect(await db.claimDao.watchChecklist('c1').first, isEmpty);
    expect(await db.claimDao.watchAllLinks().first, isEmpty);
    expect((await db.claimDao.watchUnclaimedBills().first).length, 1);
  });

  test('checklist orders by sortOrder', () async {
    await addClaim('c1');
    for (final (i, label) in ['Form', 'Bills', 'Reports'].indexed) {
      await db.claimDao.upsertChecklistItem(ClaimChecklistItemsCompanion(
        id: Value('i$i'),
        claimId: const Value('c1'),
        label: Value(label),
        sortOrder: Value(i),
      ));
    }
    final items = await db.claimDao.watchChecklist('c1').first;
    expect(items.map((i) => i.label), ['Form', 'Bills', 'Reports']);
  });
}
