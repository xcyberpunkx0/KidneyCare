# Insurance Claims Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Track health-insurance reimbursement claims over the vault's existing documents: bundle bills into claims, walk them through draft → submitted → outcome, track money claimed vs recovered, keep a per-claim checklist, and remind the caregiver before unclaimed bills pass the insurer's submission window.

**Architecture:** New `lib/features/claims/` feature (feature-first clean architecture) over four new Drift tables (schema v5 → v6, additive only). A claim links 1..N existing documents through a junction table; "unclaimed" is always derived by query, never stored. Reminders extend the existing `ReminderService.sync` plan-rebuild model. Pure calculation (status transitions, deadline math, money formatting) lives in `lib/shared/domain/` so both core services and the feature can import it.

**Tech Stack:** Flutter 3.44 / Dart 3.12, Riverpod 3, GoRouter, Drift + SQLCipher, flutter_local_notifications, gen_l10n (en + hi), uuid, intl.

**Spec:** `docs/superpowers/specs/2026-08-15-insurance-claims-design.md`

## Global Constraints

- Primary keys are **text UUIDs** (`Uuid().v4()`), matching every existing table. (The spec's sketch said int autoincrement; the spec has been corrected — codebase convention wins.)
- Money is stored as **integer paise** (`claimedAmountPaise`), never floats.
- Riverpod 3: plain `Notifier` + `NotifierProvider.autoDispose`; async values read with `.value` (never `valueOrNull` on AsyncValue).
- Every user-visible string goes through `context.l10n` with keys in **both** `lib/l10n/app_en.arb` and `lib/l10n/app_hi.arb`; run `flutter gen-l10n` after editing arb files.
- Timeline event titles and notification bodies are hardcoded English (existing convention — see `dialysis_repository_impl.dart` and `reminder_service.dart`).
- Repositories return `Result<T>` / `AppFailure`; UI never sees raw exceptions.
- Enums own presentation: localized labels live in `lib/core/l10n/l10n_x.dart`, never in widgets.
- After changing tables: `dart run build_runner build --delete-conflicting-outputs`.
- Windows note: if a Drift test fails with `Failed to load dynamic library sqlite3.dll`, download the precompiled sqlite3 DLL from https://www.sqlite.org/download.html (sqlite-dll-win-x64) and place `sqlite3.dll` in the project root; add `sqlite3.dll` to `.gitignore`.
- Commit after each task with the trailer: `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.

---

### Task 1: ClaimStatus enum with transition rules

**Files:**
- Create: `lib/shared/domain/claim_status.dart`
- Test: `test/shared/claim_status_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum ClaimStatus { draft, submitted, approved, partiallySettled, rejected }` with `bool canTransitionTo(ClaimStatus next)` and `bool get isOutcome`. Stored in Drift via `textEnum<ClaimStatus>()` (Task 3) — **never reorder or rename values** once shipped.

- [ ] **Step 1: Write the failing test**

```dart
// test/shared/claim_status_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/shared/domain/claim_status.dart';

void main() {
  group('ClaimStatus.canTransitionTo', () {
    test('draft can only be submitted', () {
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.submitted), isTrue);
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.approved), isFalse);
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.rejected), isFalse);
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.draft), isFalse);
    });

    test('submitted can reach every outcome and nothing else', () {
      expect(
          ClaimStatus.submitted.canTransitionTo(ClaimStatus.approved), isTrue);
      expect(
          ClaimStatus.submitted.canTransitionTo(ClaimStatus.partiallySettled),
          isTrue);
      expect(
          ClaimStatus.submitted.canTransitionTo(ClaimStatus.rejected), isTrue);
      expect(ClaimStatus.submitted.canTransitionTo(ClaimStatus.draft), isFalse);
    });

    test('rejected can reopen as draft; settled outcomes are terminal', () {
      expect(ClaimStatus.rejected.canTransitionTo(ClaimStatus.draft), isTrue);
      expect(
          ClaimStatus.rejected.canTransitionTo(ClaimStatus.submitted), isFalse);
      for (final next in ClaimStatus.values) {
        expect(ClaimStatus.approved.canTransitionTo(next), isFalse);
        expect(ClaimStatus.partiallySettled.canTransitionTo(next), isFalse);
      }
    });

    test('isOutcome covers exactly the three end states', () {
      expect(ClaimStatus.draft.isOutcome, isFalse);
      expect(ClaimStatus.submitted.isOutcome, isFalse);
      expect(ClaimStatus.approved.isOutcome, isTrue);
      expect(ClaimStatus.partiallySettled.isOutcome, isTrue);
      expect(ClaimStatus.rejected.isOutcome, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/shared/claim_status_test.dart`
Expected: FAIL — `claim_status.dart` does not exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/shared/domain/claim_status.dart

/// Lifecycle of an insurance reimbursement claim.
///
/// Persisted by name via Drift's `textEnum` — never rename or reorder
/// values once released.
enum ClaimStatus {
  /// Collecting bills; nothing sent to the insurer yet.
  draft,

  /// Handed to the insurer/TPA; awaiting a decision.
  submitted,

  /// Fully approved and paid out.
  approved,

  /// Paid, but less than the claimed amount.
  partiallySettled,

  /// Declined. May be reopened as [draft] for resubmission.
  rejected;

  /// Whether this claim has reached an end state.
  bool get isOutcome =>
      this == approved || this == partiallySettled || this == rejected;

  /// Legal moves: draft → submitted → outcome; rejected → draft.
  bool canTransitionTo(ClaimStatus next) => switch ((this, next)) {
        (draft, submitted) => true,
        (submitted, approved) ||
        (submitted, partiallySettled) ||
        (submitted, rejected) =>
          true,
        (rejected, draft) => true,
        _ => false,
      };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/shared/claim_status_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/shared/domain/claim_status.dart test/shared/claim_status_test.dart
git commit -m "feat: add ClaimStatus enum with transition rules"
```

---

### Task 2: Money formatting and deadline math

**Files:**
- Create: `lib/shared/domain/claim_money.dart`
- Create: `lib/shared/domain/claim_deadlines.dart`
- Test: `test/shared/claim_money_test.dart`
- Test: `test/shared/claim_deadlines_test.dart`

**Interfaces:**
- Consumes: nothing (pure Dart + intl).
- Produces:
  - `String formatPaise(int paise)` → `"₹12,400"` / `"₹99.50"` (en_IN digit grouping).
  - `int? parsePaise(String input)` → rupees text (commas/₹ allowed) to paise, null when invalid.
  - `DateTime claimDeadline(DateTime billDate, int windowDays)`
  - `int daysUntilDeadline(DateTime billDate, int windowDays, DateTime now)` (negative = overdue)
  - `class BillReminder { final int id; final DateTime at; final String billTitle; final int daysLeft; }`
  - `List<BillReminder> planBillReminders({required List<({String title, DateTime date})> bills, required int windowDays, required DateTime now})` — notification ids start at 1000.

- [ ] **Step 1: Write the failing money test**

```dart
// test/shared/claim_money_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/shared/domain/claim_money.dart';

void main() {
  group('formatPaise', () {
    test('whole rupees drop the decimals and use Indian grouping', () {
      expect(formatPaise(1240000), '₹12,400');
      expect(formatPaise(123456700), '₹12,34,567');
      expect(formatPaise(0), '₹0');
    });

    test('fractional rupees keep two decimals', () {
      expect(formatPaise(9950), '₹99.50');
    });
  });

  group('parsePaise', () {
    test('accepts plain, comma-grouped and ₹-prefixed rupees', () {
      expect(parsePaise('12400'), 1240000);
      expect(parsePaise('12,400'), 1240000);
      expect(parsePaise('₹ 12,400'), 1240000);
      expect(parsePaise('99.50'), 9950);
    });

    test('rejects junk, negatives and blank input', () {
      expect(parsePaise('twelve'), isNull);
      expect(parsePaise('-5'), isNull);
      expect(parsePaise(''), isNull);
      expect(parsePaise('12.345'), isNull);
    });
  });
}
```

- [ ] **Step 2: Write the failing deadline test**

```dart
// test/shared/claim_deadlines_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/shared/domain/claim_deadlines.dart';

void main() {
  final now = DateTime(2026, 8, 15, 12); // fixed "today", noon

  group('claimDeadline / daysUntilDeadline', () {
    test('deadline is billDate + window, date arithmetic not duration', () {
      expect(claimDeadline(DateTime(2026, 8, 1), 30), DateTime(2026, 8, 31));
    });

    test('daysUntilDeadline counts calendar days and goes negative', () {
      expect(daysUntilDeadline(DateTime(2026, 8, 1), 30, now), 16);
      expect(daysUntilDeadline(DateTime(2026, 7, 1), 30, now), lessThan(0));
    });
  });

  group('planBillReminders', () {
    test('schedules 9 AM five days before the deadline, ids from 1000', () {
      final plan = planBillReminders(
        bills: [(title: 'Dialysis bill', date: DateTime(2026, 8, 1))],
        windowDays: 30,
        now: now,
      );
      expect(plan, hasLength(1));
      expect(plan.single.id, 1000);
      expect(plan.single.at, DateTime(2026, 8, 26, 9));
      expect(plan.single.daysLeft, 5);
    });

    test('inside the 5-day window it fires at the next 9 AM instead', () {
      final plan = planBillReminders(
        bills: [(title: 'Late bill', date: DateTime(2026, 7, 20))],
        windowDays: 30, // deadline Aug 19; minus 5 days is already past
        now: now, // Aug 15 noon → next 9 AM is Aug 16
        );
      expect(plan.single.at, DateTime(2026, 8, 16, 9));
    });

    test('bills past their deadline are silent (UI-only)', () {
      final plan = planBillReminders(
        bills: [(title: 'Expired bill', date: DateTime(2026, 6, 1))],
        windowDays: 30,
        now: now,
      );
      expect(plan, isEmpty);
    });

    test('ids increment per bill', () {
      final plan = planBillReminders(
        bills: [
          (title: 'A', date: DateTime(2026, 8, 1)),
          (title: 'B', date: DateTime(2026, 8, 5)),
        ],
        windowDays: 30,
        now: now,
      );
      expect(plan.map((r) => r.id), [1000, 1001]);
    });
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `flutter test test/shared/claim_money_test.dart test/shared/claim_deadlines_test.dart`
Expected: FAIL — files do not exist.

- [ ] **Step 4: Write the implementations**

```dart
// lib/shared/domain/claim_money.dart
import 'package:intl/intl.dart';

/// Formats integer paise as Indian rupees: `formatPaise(1240000)` →
/// "₹12,400". Whole-rupee amounts drop the decimals.
String formatPaise(int paise) {
  final format = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: paise % 100 == 0 ? 0 : 2,
  );
  return format.format(paise / 100);
}

/// Parses caregiver-typed rupees ("12,400", "₹ 99.50") into paise.
/// Null when the input is not a non-negative amount with at most two
/// decimal places.
int? parsePaise(String input) {
  final cleaned = input.replaceAll('₹', '').replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(cleaned);
  if (match == null) return null;
  final rupees = int.parse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  return rupees * 100 + int.parse(fraction);
}
```

```dart
// lib/shared/domain/claim_deadlines.dart

/// Deadline math for unclaimed bills. Pure so both the reminder service
/// and the claims UI share one definition of "expiring".

/// Last day the insurer accepts the bill: bill date + submission window.
/// Calendar-day arithmetic (DST-proof), normalized to midnight.
DateTime claimDeadline(DateTime billDate, int windowDays) =>
    DateTime(billDate.year, billDate.month, billDate.day + windowDays);

/// Whole calendar days from [now] to the deadline; negative when overdue.
int daysUntilDeadline(DateTime billDate, int windowDays, DateTime now) {
  final deadline = claimDeadline(billDate, windowDays);
  final today = DateTime(now.year, now.month, now.day);
  return deadline.difference(today).inDays;
}

/// One scheduled "claim this bill" notification.
class BillReminder {
  const BillReminder({
    required this.id,
    required this.at,
    required this.billTitle,
    required this.daysLeft,
  });

  /// Notification id. Claims own the 1000+ range (doses count up from 1,
  /// the dialysis reminder is 900).
  final int id;
  final DateTime at;
  final String billTitle;
  final int daysLeft;
}

/// Builds the notification plan for unclaimed bills: 9 AM five days
/// before each deadline, or the next 9 AM when already inside that
/// window. Bills past their deadline are dropped — nagging about the
/// unfixable helps no one; the UI still lists them.
List<BillReminder> planBillReminders({
  required List<({String title, DateTime date})> bills,
  required int windowDays,
  required DateTime now,
}) {
  final plan = <BillReminder>[];
  var id = 1000;
  for (final bill in bills) {
    final deadline = claimDeadline(bill.date, windowDays);
    if (!deadline.isAfter(now)) continue;
    var at = DateTime(deadline.year, deadline.month, deadline.day - 5, 9);
    if (!at.isAfter(now)) {
      final todayNine = DateTime(now.year, now.month, now.day, 9);
      at = todayNine.isAfter(now)
          ? todayNine
          : todayNine.add(const Duration(days: 1));
    }
    if (!deadline.isAfter(at)) continue;
    plan.add(BillReminder(
      id: id++,
      at: at,
      billTitle: bill.title,
      daysLeft: deadline.difference(DateTime(at.year, at.month, at.day)).inDays,
    ));
  }
  return plan;
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/shared/claim_money_test.dart test/shared/claim_deadlines_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/shared/domain/claim_money.dart lib/shared/domain/claim_deadlines.dart test/shared/claim_money_test.dart test/shared/claim_deadlines_test.dart
git commit -m "feat: add claim money formatting and deadline planning"
```

---

### Task 3: Schema v6 — tables, migration, DAO registration

**Files:**
- Modify: `lib/core/storage/tables.dart` (append four tables)
- Modify: `lib/core/storage/app_database.dart` (register tables + DAO, bump version, extend migration)
- Create: `lib/core/storage/daos/claim_dao.dart` (skeleton; queries come in Task 4)
- Create: `drift_schemas/` (schema dumps), `test/generated_migrations/` (generated)
- Test: `test/core/claims_migration_test.dart`

**Interfaces:**
- Consumes: `ClaimStatus` (Task 1).
- Produces: Drift row classes `InsurancePolicy`, `Claim`, `ClaimDocument`, `ClaimChecklistItem`; companions `InsurancePoliciesCompanion`, `ClaimsCompanion`, `ClaimDocumentsCompanion`, `ClaimChecklistItemsCompanion`; `db.claimDao`. Column names exactly as written below — Tasks 4–13 depend on them.

- [ ] **Step 1: Dump the v5 schema BEFORE touching any table**

```bash
dart run drift_dev schema dump lib/core/storage/app_database.dart drift_schemas/
```

Expected: creates `drift_schemas/drift_schema_v5.json`. Do this first — once the code says v6 the v5 schema is unrecoverable from source.

- [ ] **Step 2: Append the new tables to `tables.dart`**

Add `import '../../shared/domain/claim_status.dart';` at the top, then append:

```dart
/// A health-insurance policy claims are filed against. Usually one row;
/// modeled as a list because top-up policies exist.
class InsurancePolicies extends Table {
  TextColumn get id => text()();
  TextColumn get insurerName => text()();
  TextColumn get policyNumber => text()();
  TextColumn get tpaName => text().withDefault(const Constant(''))();

  /// Days from a bill's date until the insurer stops accepting it.
  IntColumn get claimWindowDays =>
      integer().withDefault(const Constant(30))();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One reimbursement claim: a bundle of vault documents moving through
/// draft → submitted → outcome. Money is integer paise, never floats.
class Claims extends Table {
  TextColumn get id => text()();
  TextColumn get policyId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get status => textEnum<ClaimStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get submittedOn => dateTime().nullable()();
  DateTimeColumn get settledOn => dateTime().nullable()();
  IntColumn get claimedAmountPaise => integer().nullable()();
  IntColumn get approvedAmountPaise => integer().nullable()();

  /// Claim number assigned by the insurer/TPA after submission.
  TextColumn get insurerRef => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Documents attached to a claim. A document with no row here is
/// "unclaimed" — that state is always derived, never stored.
class ClaimDocuments extends Table {
  TextColumn get claimId => text()();
  TextColumn get documentId => text()();

  @override
  Set<Column<Object>> get primaryKey => {claimId, documentId};
}

/// Per-claim submission checklist. Labels are copied in at creation time
/// (localized then), so past claims keep the wording they were made with.
class ClaimChecklistItems extends Table {
  TextColumn get id => text()();
  TextColumn get claimId => text()();
  TextColumn get label => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

- [ ] **Step 3: Create the ClaimDao skeleton**

```dart
// lib/core/storage/daos/claim_dao.dart
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
```

- [ ] **Step 4: Register in `app_database.dart`**

Add `import 'daos/claim_dao.dart';` with the other DAO imports. In the `@DriftDatabase` annotation append `InsurancePolicies, Claims, ClaimDocuments, ClaimChecklistItems,` to `tables:` and `ClaimDao,` to `daos:`. Bump `schemaVersion` to `6` and extend `onUpgrade` after the `from < 5` block:

```dart
        if (from < 6) {
          await m.createTable(insurancePolicies);
          await m.createTable(claims);
          await m.createTable(claimDocuments);
          await m.createTable(claimChecklistItems);
        }
```

- [ ] **Step 5: Run codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: succeeds; `claim_dao.g.dart` and updated `app_database.g.dart` appear.

- [ ] **Step 6: Dump v6 schema and generate migration test helpers**

```bash
dart run drift_dev schema dump lib/core/storage/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```

Expected: `drift_schemas/drift_schema_v6.json` plus generated helper files under `test/generated_migrations/`.

- [ ] **Step 7: Write the migration test**

```dart
// test/core/claims_migration_test.dart
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';

import '../generated_migrations/schema.dart';

void main() {
  // If this fails on Windows with "Failed to load dynamic library
  // sqlite3.dll", see the sqlite3.dll note in the plan's Global
  // Constraints.
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v5 vault upgrades cleanly to v6', () async {
    final connection = await verifier.startAt(5);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);
  });
}
```

- [ ] **Step 8: Run the migration test**

Run: `flutter test test/core/claims_migration_test.dart`
Expected: PASS. (Apply the sqlite3.dll contingency if the library fails to load.)

- [ ] **Step 9: Run the full suite to prove nothing regressed**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; all tests pass.

- [ ] **Step 10: Commit**

```bash
git add lib/core/storage/ drift_schemas/ test/generated_migrations/ test/core/claims_migration_test.dart pubspec.lock
git commit -m "feat: add claims schema v6 with verified v5 migration"
```

---

### Task 4: ClaimDao queries

**Files:**
- Modify: `lib/core/storage/daos/claim_dao.dart`
- Test: `test/core/claim_dao_test.dart`

**Interfaces:**
- Consumes: Task 3's tables/companions; `DocumentType` from `shared/domain/document_type.dart`.
- Produces (exact signatures — repository and providers call these):
  - `Stream<List<Claim>> watchAllClaims()` — newest `createdAt` first
  - `Stream<Claim?> watchClaim(String id)`
  - `Stream<List<Document>> watchDocumentsForClaim(String claimId)`
  - `Stream<List<ClaimDocument>> watchAllLinks()`
  - `Stream<List<ClaimChecklistItem>> watchChecklist(String claimId)` — by `sortOrder`
  - `Stream<List<Document>> watchUnclaimedBills()` — oldest first
  - `Stream<List<InsurancePolicy>> watchPolicies()`
  - `Future<Claim?> getClaimById(String id)`
  - `Future<int> countDocumentsForClaim(String claimId)`
  - `Future<void> upsertClaim(ClaimsCompanion entry)`
  - `Future<void> deleteClaimCascade(String id)` — claim + links + checklist in one transaction
  - `Future<void> attachDocument(String claimId, String documentId)`
  - `Future<void> detachDocument(String claimId, String documentId)`
  - `Future<void> upsertChecklistItem(ClaimChecklistItemsCompanion entry)`
  - `Future<void> deleteChecklistItem(String id)`
  - `Future<void> upsertPolicy(InsurancePoliciesCompanion entry)`
  - `Future<void> deletePolicy(String id)`

- [ ] **Step 1: Write the failing tests**

```dart
// test/core/claim_dao_test.dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/claim_dao_test.dart`
Expected: FAIL — methods not defined.

- [ ] **Step 3: Implement the queries in `claim_dao.dart`**

Replace the class body (keep the annotation and constructor):

```dart
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

  Future<void> deletePolicy(String id) =>
      (delete(insurancePolicies)..where((t) => t.id.equals(id))).go();
```

Add `import '../../../shared/domain/document_type.dart';` to the imports.

- [ ] **Step 4: Regenerate and run the tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/claim_dao_test.dart
```

Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/storage/daos/ test/core/claim_dao_test.dart
git commit -m "feat: add ClaimDao queries for claims, links, checklist, policies"
```

---

### Task 5: Timeline event type + every claims l10n string

**Files:**
- Modify: `lib/shared/domain/timeline_event_type.dart`
- Modify: `lib/core/l10n/l10n_x.dart`
- Modify: `lib/core/widgets/record_tile.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_hi.arb`

**Interfaces:**
- Consumes: nothing new.
- Produces: `TimelineEventType.claim`; `ClaimStatusL10n.localizedLabel(AppLocalizations)`; all `l10n.claim*` / `l10n.policy*` / `l10n.checklist*` keys used by Tasks 8–13 (exact key list below).

- [ ] **Step 1: Add the enum value**

In `timeline_event_type.dart` append to the enum (before the `;`):

```dart
  claim('Insurance claim');
```

(becomes `symptom('Symptom'), claim('Insurance claim');`)

- [ ] **Step 2: Add every key to `app_en.arb`**

Append before the closing `}` (keep valid JSON — mind the commas):

```json
  "eventClaim": "Insurance claim",
  "claimsTitle": "Claims",
  "claimsAction": "Claims",
  "claimsEmpty": "No claims yet. Bundle bills from the vault into a claim and track it to settlement.",
  "claimsYtdLine": "{claimed} claimed · {recovered} recovered this year",
  "@claimsYtdLine": {
    "placeholders": {
      "claimed": {"type": "String"},
      "recovered": {"type": "String"}
    }
  },
  "unclaimedBillsChip": "{count} unclaimed {count, plural, =1{bill} other{bills}}",
  "@unclaimedBillsChip": {
    "placeholders": {"count": {"type": "int"}}
  },
  "claimSectionAttention": "Needs attention",
  "claimSectionInProgress": "In progress",
  "claimSectionHistory": "Settled & rejected",
  "claimDocCount": "{count} {count, plural, =1{document} other{documents}}",
  "@claimDocCount": {
    "placeholders": {"count": {"type": "int"}}
  },
  "claimStatusDraft": "Draft",
  "claimStatusSubmitted": "Submitted",
  "claimStatusApproved": "Approved",
  "claimStatusPartiallySettled": "Partially settled",
  "claimStatusRejected": "Rejected",
  "claimNew": "New claim",
  "claimEdit": "Edit claim",
  "claimTitleLabel": "Claim title",
  "claimTitleHint": "e.g. August dialysis and medicines",
  "claimTitleRequired": "Give the claim a short title.",
  "claimPolicyLabel": "Policy",
  "claimNoPolicyYet": "Add your policy in Settings to enable deadline reminders.",
  "claimPickDocuments": "Attach documents",
  "claimPickDocumentsSub": "Unclaimed bills are pre-selected",
  "claimDocumentsSection": "Documents",
  "claimChecklistSection": "Checklist",
  "claimChecklistAddHint": "Add checklist item…",
  "claimAmountClaimed": "Claimed",
  "claimAmountApproved": "Approved",
  "claimAmountHint": "Amount in ₹",
  "claimAmountInvalid": "Enter a valid amount in rupees.",
  "claimInsurerRefLabel": "Insurer claim no.",
  "claimNotesLabel": "Notes",
  "claimMarkSubmitted": "Mark submitted",
  "claimRecordOutcome": "Record outcome",
  "claimReopen": "Reopen as draft",
  "claimDelete": "Delete claim",
  "claimDeleteConfirm": "Delete this claim? Its documents stay in the vault.",
  "claimSubmittedOn": "Submitted on",
  "claimSettledOn": "Settled on",
  "claimCreatedOn": "Created on",
  "claimNoDocsError": "Attach at least one document before submitting.",
  "claimApprovedExceedsWarning": "Approved amount is more than claimed — double-check the letter.",
  "claimOutcomeApproved": "Approved in full",
  "claimOutcomePartial": "Partially settled",
  "claimOutcomeRejected": "Rejected",
  "claimDaysLeft": "{count} {count, plural, =1{day} other{days}} left to claim",
  "@claimDaysLeft": {
    "placeholders": {"count": {"type": "int"}}
  },
  "claimOverdue": "Past claim window",
  "claimAwaitingLong": "Submitted {count} days ago — worth a follow-up call",
  "@claimAwaitingLong": {
    "placeholders": {"count": {"type": "int"}}
  },
  "claimGlanceTitle": "CLAIMS · {count}",
  "@claimGlanceTitle": {
    "placeholders": {"count": {"type": "int"}}
  },
  "policyTitle": "Insurance policy",
  "policySettingsSub": "Insurer, policy number, claim window",
  "policyInsurerLabel": "Insurer",
  "policyNumberLabel": "Policy number",
  "policyTpaLabel": "TPA (optional)",
  "policyWindowLabel": "Claim window (days)",
  "policyWindowInvalid": "Enter the number of days bills stay claimable.",
  "policyRequired": "Insurer and policy number are required.",
  "checklistClaimForm": "Signed claim form",
  "checklistOriginalBills": "Original bills",
  "checklistPrescriptionCopy": "Prescription copy",
  "checklistLabReports": "Lab reports",
  "checklistPolicyIdCopy": "Policy & ID copy"
```

- [ ] **Step 3: Add the same keys to `app_hi.arb`**

Same key set with Hindi values (placeholder `@` metadata only lives in the en file):

```json
  "eventClaim": "बीमा क्लेम",
  "claimsTitle": "क्लेम",
  "claimsAction": "क्लेम",
  "claimsEmpty": "अभी कोई क्लेम नहीं। वॉल्ट के बिलों को एक क्लेम में जोड़ें और निपटान तक ट्रैक करें।",
  "claimsYtdLine": "इस साल {claimed} क्लेम किया · {recovered} वापस मिला",
  "unclaimedBillsChip": "{count} बिना क्लेम {count, plural, =1{बिल} other{बिल}}",
  "claimSectionAttention": "ध्यान चाहिए",
  "claimSectionInProgress": "प्रगति में",
  "claimSectionHistory": "निपटाए और अस्वीकृत",
  "claimDocCount": "{count} {count, plural, =1{दस्तावेज़} other{दस्तावेज़}}",
  "claimStatusDraft": "ड्राफ़्ट",
  "claimStatusSubmitted": "जमा किया गया",
  "claimStatusApproved": "स्वीकृत",
  "claimStatusPartiallySettled": "आंशिक रूप से निपटाया",
  "claimStatusRejected": "अस्वीकृत",
  "claimNew": "नया क्लेम",
  "claimEdit": "क्लेम बदलें",
  "claimTitleLabel": "क्लेम का शीर्षक",
  "claimTitleHint": "जैसे अगस्त डायलिसिस और दवाइयाँ",
  "claimTitleRequired": "क्लेम को एक छोटा शीर्षक दें।",
  "claimPolicyLabel": "पॉलिसी",
  "claimNoPolicyYet": "समय-सीमा रिमाइंडर के लिए सेटिंग्स में अपनी पॉलिसी जोड़ें।",
  "claimPickDocuments": "दस्तावेज़ जोड़ें",
  "claimPickDocumentsSub": "बिना क्लेम वाले बिल पहले से चुने हैं",
  "claimDocumentsSection": "दस्तावेज़",
  "claimChecklistSection": "चेकलिस्ट",
  "claimChecklistAddHint": "चेकलिस्ट आइटम जोड़ें…",
  "claimAmountClaimed": "क्लेम किया",
  "claimAmountApproved": "स्वीकृत",
  "claimAmountHint": "राशि ₹ में",
  "claimAmountInvalid": "रुपये में सही राशि लिखें।",
  "claimInsurerRefLabel": "बीमा क्लेम नंबर",
  "claimNotesLabel": "नोट",
  "claimMarkSubmitted": "जमा किया चिह्नित करें",
  "claimRecordOutcome": "नतीजा दर्ज करें",
  "claimReopen": "फिर से ड्राफ़्ट करें",
  "claimDelete": "क्लेम हटाएँ",
  "claimDeleteConfirm": "यह क्लेम हटाएँ? दस्तावेज़ वॉल्ट में बने रहेंगे।",
  "claimSubmittedOn": "जमा करने की तारीख़",
  "claimSettledOn": "निपटान की तारीख़",
  "claimCreatedOn": "बनाने की तारीख़",
  "claimNoDocsError": "जमा करने से पहले कम से कम एक दस्तावेज़ जोड़ें।",
  "claimApprovedExceedsWarning": "स्वीकृत राशि क्लेम से ज़्यादा है — पत्र फिर से जाँचें।",
  "claimOutcomeApproved": "पूरा स्वीकृत",
  "claimOutcomePartial": "आंशिक रूप से निपटाया",
  "claimOutcomeRejected": "अस्वीकृत",
  "claimDaysLeft": "क्लेम के लिए {count} {count, plural, =1{दिन} other{दिन}} बाक़ी",
  "claimOverdue": "क्लेम की समय-सीमा निकल गई",
  "claimAwaitingLong": "{count} दिन पहले जमा किया — फ़ॉलो-अप कॉल करें",
  "claimGlanceTitle": "क्लेम · {count}",
  "policyTitle": "बीमा पॉलिसी",
  "policySettingsSub": "बीमा कंपनी, पॉलिसी नंबर, क्लेम अवधि",
  "policyInsurerLabel": "बीमा कंपनी",
  "policyNumberLabel": "पॉलिसी नंबर",
  "policyTpaLabel": "TPA (वैकल्पिक)",
  "policyWindowLabel": "क्लेम अवधि (दिन)",
  "policyWindowInvalid": "बिल कितने दिन क्लेम हो सकते हैं, वह संख्या लिखें।",
  "policyRequired": "बीमा कंपनी और पॉलिसी नंबर ज़रूरी हैं।",
  "checklistClaimForm": "हस्ताक्षरित क्लेम फ़ॉर्म",
  "checklistOriginalBills": "मूल बिल",
  "checklistPrescriptionCopy": "पर्चे की कॉपी",
  "checklistLabReports": "लैब रिपोर्ट",
  "checklistPolicyIdCopy": "पॉलिसी और पहचान-पत्र की कॉपी"
```

- [ ] **Step 4: Regenerate localizations**

```bash
flutter gen-l10n
```

Expected: succeeds with no untranslated-key warnings for these keys.

- [ ] **Step 5: Wire the new enum value into the two exhaustive switches**

In `l10n_x.dart`, extend `TimelineEventTypeL10n`'s switch with:

```dart
        TimelineEventType.claim => l10n.eventClaim,
```

and add a new extension at the bottom of the file:

```dart
extension ClaimStatusL10n on ClaimStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ClaimStatus.draft => l10n.claimStatusDraft,
        ClaimStatus.submitted => l10n.claimStatusSubmitted,
        ClaimStatus.approved => l10n.claimStatusApproved,
        ClaimStatus.partiallySettled => l10n.claimStatusPartiallySettled,
        ClaimStatus.rejected => l10n.claimStatusRejected,
      };
}
```

with `import '../../shared/domain/claim_status.dart';` added at the top.

In `record_tile.dart`, extend `_iconFor`'s switch with:

```dart
      TimelineEventType.claim =>
        (Icons.receipt_long_outlined, colors.greenBg, colors.green),
```

- [ ] **Step 6: Verify the compiler is satisfied**

Run: `flutter analyze && flutter test`
Expected: clean — if any other exhaustive switch over `TimelineEventType` exists, the analyzer names it; add the `claim` arm there following the same pattern.

- [ ] **Step 7: Commit**

```bash
git add lib/shared/domain/timeline_event_type.dart lib/core/l10n/l10n_x.dart lib/core/widgets/record_tile.dart lib/l10n/
git commit -m "feat: add claim timeline type and full claims localization (en/hi)"
```

---

### Task 6: ClaimsRepository — rules, timeline writes

**Files:**
- Create: `lib/features/claims/domain/repositories/claims_repository.dart`
- Create: `lib/features/claims/data/repository_impl/claims_repository_impl.dart`
- Test: `test/features/claims/claims_repository_test.dart`

**Interfaces:**
- Consumes: `db.claimDao` (Task 4), `db.timelineDao`, `ClaimStatus`, `formatPaise`, `Result`/`AppFailure`.
- Produces:

```dart
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
```

  plus `final claimsRepositoryProvider = Provider<ClaimsRepository>` in the impl file (existing convention).

**Rules enforced here (spec):** `markSubmitted` fails with `ValidationFailure` when the claim isn't `draft` or has zero documents. `recordOutcome` requires status `submitted` and an outcome status. `reopenAsDraft` requires `rejected`, clears `submittedOn`/`settledOn`/amounts/`insurerRef`. Submit and outcome each write one timeline event (English, type `TimelineEventType.claim`), e.g. title `"Claim submitted · ₹12,400"` / `"Claim approved · ₹11,100"`, subtitle = claim title.

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/claims/claims_repository_test.dart
import 'package:drift/drift.dart';
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/claims/claims_repository_test.dart`
Expected: FAIL — files do not exist.

- [ ] **Step 3: Write the interface**

```dart
// lib/features/claims/domain/repositories/claims_repository.dart
import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/claim_status.dart';

/// Vault-backed store of insurance reimbursement claims.
///
/// Enforces the claim lifecycle: draft → submitted → outcome, with
/// rejected claims reopenable as drafts. All writes are transactional
/// and status changes append to the medical timeline.
abstract interface class ClaimsRepository {
  // ... exact signatures from the Interfaces block above, verbatim ...
}
```

(Copy the full interface from the Interfaces block — every method, verbatim.)

- [ ] **Step 4: Write the implementation**

```dart
// lib/features/claims/data/repository_impl/claims_repository_impl.dart
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
        final current =
            await _db.claimDao.watchDocumentsForClaim(claimId).first;
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
      final items = await _db.claimDao.watchChecklist(claimId).first;
      await _db.claimDao.upsertChecklistItem(ClaimChecklistItemsCompanion(
        id: Value(_uuid.v4()),
        claimId: Value(claimId),
        label: Value(label),
        sortOrder: Value(items.length),
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
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/features/claims/claims_repository_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/features/claims/ test/features/claims/
git commit -m "feat: add ClaimsRepository with lifecycle rules and timeline writes"
```

---

### Task 7: Riverpod providers for the claims feature

**Files:**
- Create: `lib/features/claims/presentation/controllers/claims_providers.dart`
- Test: `test/features/claims/claims_providers_test.dart`

**Interfaces:**
- Consumes: `claimsRepositoryProvider` (Task 6), `daysUntilDeadline` (Task 2).
- Produces (UI tasks 8–13 watch these):
  - `final claimsListProvider = StreamProvider.autoDispose<List<Claim>>`
  - `final claimLinksProvider = StreamProvider.autoDispose<List<ClaimDocument>>`
  - `final unclaimedBillsProvider = StreamProvider.autoDispose<List<Document>>`
  - `final policiesProvider = StreamProvider.autoDispose<List<InsurancePolicy>>`
  - `final claimProvider = StreamProvider.autoDispose.family<Claim?, String>`
  - `final claimDocumentsProvider = StreamProvider.autoDispose.family<List<Document>, String>`
  - `final claimChecklistProvider = StreamProvider.autoDispose.family<List<ClaimChecklistItem>, String>`
  - `({int claimedPaise, int recoveredPaise}) ytdTotals(List<Claim> claims, DateTime now)` — pure, exported for tests
  - `List<Claim> staleSubmitted(List<Claim> claims, DateTime now)` — submitted > 30 days, pure

- [ ] **Step 1: Write the failing test for the pure helpers**

```dart
// test/features/claims/claims_providers_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/claims/claims_providers_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write the providers file**

```dart
// lib/features/claims/presentation/controllers/claims_providers.dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/claims/claims_providers_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/claims/presentation/controllers/ test/features/claims/claims_providers_test.dart
git commit -m "feat: add claims providers with YTD and stale-claim helpers"
```

---

### Task 8: Routes, claims list page, Home quick action

**Files:**
- Modify: `lib/core/router/routes.dart`, `lib/core/router/app_router.dart`
- Create: `lib/features/claims/presentation/pages/claims_page.dart`
- Create: `lib/features/claims/presentation/widgets/claim_card.dart`
- Modify: `lib/features/home/presentation/widgets/quick_actions_row.dart`

**Interfaces:**
- Consumes: Task 7 providers, `ClaimStatusL10n`, `formatPaise`, `daysUntilDeadline`.
- Produces: routes `/claims` (name `claims`), `/claims/new` (name `claimEdit`, optional `?id=` query param for editing a draft), `/claims/:id` (name `claimDetail`); widget `ClaimCard({required Claim claim, required int docCount, VoidCallback? onTap})`. Tasks 10, 11, 13 navigate by these names.

- [ ] **Step 1: Add route constants**

In `routes.dart` add to the paths: `static const claims = '/claims';` and to the names: `static const claimsName = 'claims';`.

- [ ] **Step 2: Register routes in `app_router.dart`**

Add imports for the three claims pages (detail and edit pages arrive in Tasks 10–11 — to keep every task compiling, create both files in this task as minimal `Scaffold(body: SizedBox.shrink())` placeholders that later tasks replace; each has its real signature from day one: `ClaimEditPage({this.claimId})`, `ClaimDetailPage({required this.claimId})`). Register at root level (alongside `/emergency-card` etc.):

```dart
      GoRoute(
        path: AppRoutes.claims,
        name: AppRoutes.claimsName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClaimsPage(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'claimEdit',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => ClaimEditPage(
              claimId: state.uri.queryParameters['id'],
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'claimDetail',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => ClaimDetailPage(
              claimId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
```

- [ ] **Step 3: Build `ClaimCard`**

```dart
// lib/features/claims/presentation/widgets/claim_card.dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';

/// One claim in the list: title, status chip, document count, money line.
class ClaimCard extends StatelessWidget {
  const ClaimCard({
    super.key,
    required this.claim,
    required this.docCount,
    this.onTap,
  });

  final Claim claim;
  final int docCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    final money = switch (claim.status) {
      ClaimStatus.draft => null,
      ClaimStatus.submitted => claim.claimedAmountPaise == null
          ? null
          : '${l10n.claimAmountClaimed} ${formatPaise(claim.claimedAmountPaise!)}',
      _ => claim.approvedAmountPaise == null
          ? null
          : '${l10n.claimAmountApproved} ${formatPaise(claim.approvedAmountPaise!)}',
    };
    final date = claim.settledOn ?? claim.submittedOn ?? claim.createdAt;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  claim.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.cardTitle,
                ),
              ),
              _StatusChip(status: claim.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              l10n.claimDocCount(docCount),
              if (money != null) money,
              date.monthDay,
            ].join(' · '),
            style: typo.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final (bg, fg) = switch (status) {
      ClaimStatus.draft => (colors.card, colors.muted),
      ClaimStatus.submitted => (colors.blueBg, colors.blue),
      ClaimStatus.approved => (colors.greenBg, colors.green),
      ClaimStatus.partiallySettled => (colors.amberBg, colors.amber),
      ClaimStatus.rejected => (colors.orangeBg, colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.localizedLabel(context.l10n),
        style: typo.caption
            .copyWith(color: fg, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
```

(If `colors.blueBg`/`orangeBg` etc. differ in name, use exactly the token names found in `app_colors.dart` — `record_tile.dart` already references `colors.purpleBg`, `colors.greenBg`, `colors.blueBg`, `colors.orangeBg`, `colors.amberBg`, so these exist.)

- [ ] **Step 4: Build `ClaimsPage`**

```dart
// lib/features/claims/presentation/pages/claims_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/domain/claim_deadlines.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';
import '../controllers/claims_providers.dart';
import '../widgets/claim_card.dart';

/// All claims: YTD money strip, unclaimed-bills chip, then claims grouped
/// into needs-attention / in-progress / history.
class ClaimsPage extends ConsumerWidget {
  const ClaimsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    final claims = ref.watch(claimsListProvider).value ?? const <Claim>[];
    final links =
        ref.watch(claimLinksProvider).value ?? const <ClaimDocument>[];
    final unclaimed =
        ref.watch(unclaimedBillsProvider).value ?? const <Document>[];
    final now = DateTime.now();

    final docCounts = <String, int>{};
    for (final link in links) {
      docCounts[link.claimId] = (docCounts[link.claimId] ?? 0) + 1;
    }

    final stale = staleSubmitted(claims, now).map((c) => c.id).toSet();
    final attention = claims
        .where((c) => c.status == ClaimStatus.draft || stale.contains(c.id))
        .toList();
    final inProgress = claims
        .where((c) =>
            c.status == ClaimStatus.submitted && !stale.contains(c.id))
        .toList();
    final history = claims.where((c) => c.status.isOutcome).toList();
    final totals = ytdTotals(claims, now);

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('claimEdit'),
        label: Text(l10n.claimNew),
        icon: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: claims.isEmpty && unclaimed.isEmpty
            ? EmptyState(message: l10n.claimsEmpty)
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 96),
                children: [
                  Text(l10n.claimsTitle,
                      style: typo.pageTitle.copyWith(fontSize: 25)),
                  const SizedBox(height: 6),
                  Text(
                    l10n.claimsYtdLine(
                      formatPaise(totals.claimedPaise),
                      formatPaise(totals.recoveredPaise),
                    ),
                    style: typo.caption.copyWith(color: colors.muted),
                  ),
                  if (unclaimed.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _UnclaimedStrip(bills: unclaimed),
                  ],
                  for (final (title, group) in [
                    (l10n.claimSectionAttention, attention),
                    (l10n.claimSectionInProgress, inProgress),
                    (l10n.claimSectionHistory, history),
                  ])
                    if (group.isNotEmpty) ...[
                      SectionHeader(title: title),
                      for (final claim in group) ...[
                        ClaimCard(
                          claim: claim,
                          docCount: docCounts[claim.id] ?? 0,
                          onTap: () => context.pushNamed(
                            'claimDetail',
                            pathParameters: {'id': claim.id},
                          ),
                        ),
                        const SizedBox(height: 7),
                      ],
                    ],
                ],
              ),
      ),
    );
  }
}

/// Amber strip listing bills not yet in any claim, with days-left labels
/// when a policy defines the window.
class _UnclaimedStrip extends ConsumerWidget {
  const _UnclaimedStrip({required this.bills});

  final List<Document> bills;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final policies =
        ref.watch(policiesProvider).value ?? const <InsurancePolicy>[];
    final windowDays =
        policies.isEmpty ? null : policies.first.claimWindowDays;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.amberBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.amberBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.unclaimedBillsChip(bills.length),
            style: typo.overline.copyWith(fontSize: 11, color: colors.amber),
          ),
          for (final bill in bills.take(3)) ...[
            const SizedBox(height: 5),
            Text(
              windowDays == null
                  ? bill.title
                  : switch (
                      daysUntilDeadline(bill.documentDate, windowDays, now)) {
                      < 0 => '${bill.title} — ${l10n.claimOverdue}',
                      final days =>
                        '${bill.title} — ${l10n.claimDaysLeft(days)}',
                    },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.caption.copyWith(color: colors.ink),
            ),
          ],
        ],
      ),
    );
  }
}
```

(Verify `EmptyState`'s actual constructor in `lib/core/widgets/empty_state.dart` before using — if its parameter differs from `message:`, match it.)

- [ ] **Step 5: Add the Home quick action**

In `quick_actions_row.dart` add a third `Expanded` chip after the symptom one:

```dart
          const SizedBox(width: 8),
          Expanded(
            child: _ActionChip(
              icon: Icons.receipt_long_outlined,
              label: l10n.claimsAction,
              onTap: () => context.pushNamed('claims'),
            ),
          ),
```

- [ ] **Step 6: Verify**

Run: `flutter analyze && flutter test`
Expected: clean.

- [ ] **Step 7: Commit**

```bash
git add lib/core/router/ lib/features/claims/presentation/ lib/features/home/presentation/widgets/quick_actions_row.dart
git commit -m "feat: add claims routes, list page and home quick action"
```

---

### Task 9: Policy editor in Settings

**Files:**
- Create: `lib/features/claims/presentation/pages/policy_edit_page.dart`
- Modify: `lib/core/router/app_router.dart` (route `/policy`, name `policyEdit`, root navigator)
- Modify: `lib/features/settings/presentation/pages/settings_page.dart`

**Interfaces:**
- Consumes: `policiesProvider`, `claimsRepositoryProvider.savePolicy`, l10n `policy*` keys.
- Produces: route name `policyEdit`.

- [ ] **Step 1: Build the page**

```dart
// lib/features/claims/presentation/pages/policy_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository_impl/claims_repository_impl.dart';
import '../controllers/claims_providers.dart';

/// Edit (or create) the family's insurance policy: insurer, number, TPA
/// and the claim submission window that drives deadline reminders.
class PolicyEditPage extends ConsumerStatefulWidget {
  const PolicyEditPage({super.key});

  @override
  ConsumerState<PolicyEditPage> createState() => _PolicyEditPageState();
}

class _PolicyEditPageState extends ConsumerState<PolicyEditPage> {
  final _insurer = TextEditingController();
  final _number = TextEditingController();
  final _tpa = TextEditingController();
  final _window = TextEditingController(text: '30');
  String? _policyId;
  bool _loaded = false;
  String? _error;

  @override
  void dispose() {
    _insurer.dispose();
    _number.dispose();
    _tpa.dispose();
    _window.dispose();
    super.dispose();
  }

  void _prefill(List<InsurancePolicy> policies) {
    if (_loaded || policies.isEmpty) return;
    final policy = policies.first;
    _policyId = policy.id;
    _insurer.text = policy.insurerName;
    _number.text = policy.policyNumber;
    _tpa.text = policy.tpaName;
    _window.text = '${policy.claimWindowDays}';
    _loaded = true;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final window = int.tryParse(_window.text.trim());
    if (_insurer.text.trim().isEmpty || _number.text.trim().isEmpty) {
      setState(() => _error = l10n.policyRequired);
      return;
    }
    if (window == null || window <= 0) {
      setState(() => _error = l10n.policyWindowInvalid);
      return;
    }
    final result = await ref.read(claimsRepositoryProvider).savePolicy(
          id: _policyId,
          insurerName: _insurer.text.trim(),
          policyNumber: _number.text.trim(),
          tpaName: _tpa.text.trim(),
          claimWindowDays: window,
        );
    if (!mounted) return;
    result.when(
      ok: (_) => Navigator.pop(context),
      err: (failure) => setState(() => _error = failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    ref.listen(policiesProvider, (_, next) {
      final policies = next.value;
      if (policies != null) setState(() => _prefill(policies));
    });
    _prefill(ref.watch(policiesProvider).value ?? const []);

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Text(l10n.policyTitle,
                style: typo.pageTitle.copyWith(fontSize: 25)),
            const SizedBox(height: 16),
            for (final (label, controller, keyboard) in [
              (l10n.policyInsurerLabel, _insurer, TextInputType.text),
              (l10n.policyNumberLabel, _number, TextInputType.text),
              (l10n.policyTpaLabel, _tpa, TextInputType.text),
              (l10n.policyWindowLabel, _window, TextInputType.number),
            ]) ...[
              TextField(
                controller: controller,
                keyboardType: keyboard,
                style: typo.body,
                decoration: InputDecoration(labelText: label),
              ),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              Text(_error!,
                  style: typo.caption.copyWith(color: colors.amber)),
              const SizedBox(height: 12),
            ],
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Register the route** (root level, next to `/emergency-card`):

```dart
      GoRoute(
        path: '/policy',
        name: 'policyEdit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PolicyEditPage(),
      ),
```

- [ ] **Step 3: Add the Settings tile** after the emergency-card tile in `settings_page.dart`:

```dart
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.health_and_safety_outlined,
              title: l10n.policyTitle,
              subtitle: l10n.policySettingsSub,
              onTap: () => context.pushNamed('policyEdit'),
            ),
```

- [ ] **Step 4: Verify** — `flutter analyze`, then manual: open Settings → Insurance policy, save a policy, reopen, fields persist.

- [ ] **Step 5: Commit**

```bash
git add lib/features/claims/presentation/pages/policy_edit_page.dart lib/core/router/app_router.dart lib/features/settings/
git commit -m "feat: add insurance policy editor in settings"
```

---### Task 10: Claim create/edit page with document picker

**Files:**
- Replace placeholder: `lib/features/claims/presentation/pages/claim_edit_page.dart`
- Create: `lib/features/claims/presentation/controllers/claim_edit_controller.dart`
- Test: `test/features/claims/claim_edit_controller_test.dart`

**Interfaces:**
- Consumes: `claimsRepositoryProvider`, `allDocumentsProvider` (from `documents_repository_impl.dart`), `unclaimedBillsProvider`, `policiesProvider`, l10n keys, `DocumentTypeL10n`.
- Produces: `ClaimEditPage({String? claimId})` — create when null, edit-draft when set. Controller: `class ClaimEditController extends Notifier<ClaimEditState>` with `NotifierProvider.autoDispose`; `ClaimEditState({required String title, required Set<String> selectedDocumentIds, String? policyId, String? error})`; methods `setTitle(String)`, `toggleDocument(String id)`, `preselect(Set<String> ids)`, `Future<bool> save({required String? claimId, required List<String> checklistLabels})`.

- [ ] **Step 1: Write the failing controller test**

```dart
// test/features/claims/claim_edit_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/features/claims/presentation/controllers/claim_edit_controller.dart';

void main() {
  test('validate: empty title is rejected, trimmed title accepted', () {
    expect(ClaimEditController.validateTitle('   '), isFalse);
    expect(ClaimEditController.validateTitle('August bundle'), isTrue);
  });

  test('toggling ids in a selection set', () {
    final state = ClaimEditState(
      title: '',
      selectedDocumentIds: {'a'},
    );
    final toggledOn = state.withToggled('b');
    expect(toggledOn.selectedDocumentIds, {'a', 'b'});
    final toggledOff = toggledOn.withToggled('a');
    expect(toggledOff.selectedDocumentIds, {'b'});
  });
}
```

- [ ] **Step 2: Run to verify it fails**, then **write the controller**:

```dart
// lib/features/claims/presentation/controllers/claim_edit_controller.dart
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
```

- [ ] **Step 3: Run controller test** — expect PASS.

- [ ] **Step 4: Build the page** (replacing the Task 8 placeholder):

```dart
// lib/features/claims/presentation/pages/claim_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../shared/domain/document_type.dart';
import '../../../documents/data/repository_impl/documents_repository_impl.dart';
import '../controllers/claim_edit_controller.dart';
import '../controllers/claims_providers.dart';

/// Create a claim (or edit a draft): title, policy, and a document picker
/// with unclaimed bills pre-selected.
class ClaimEditPage extends ConsumerStatefulWidget {
  const ClaimEditPage({super.key, this.claimId});

  final String? claimId;

  @override
  ConsumerState<ClaimEditPage> createState() => _ClaimEditPageState();
}

class _ClaimEditPageState extends ConsumerState<ClaimEditPage> {
  final _title = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// New claim: pre-select every unclaimed bill. Edit: load the draft's
  /// current title and attachments once streams deliver.
  void _initialize() {
    if (_initialized) return;
    final controller = ref.read(claimEditControllerProvider.notifier);
    if (widget.claimId == null) {
      final unclaimed = ref.read(unclaimedBillsProvider).value;
      final policies = ref.read(policiesProvider).value;
      if (unclaimed == null || policies == null) return;
      controller.preselect(
        unclaimed.map((d) => d.id).toSet(),
        '',
        policies.isEmpty ? null : policies.first.id,
      );
      _initialized = true;
    } else {
      final claim = ref.read(claimProvider(widget.claimId!)).value;
      final docs = ref.read(claimDocumentsProvider(widget.claimId!)).value;
      if (claim == null || docs == null) return;
      _title.text = claim.title;
      controller.preselect(
          docs.map((d) => d.id).toSet(), claim.title, claim.policyId);
      _initialized = true;
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final saved =
        await ref.read(claimEditControllerProvider.notifier).save(
      claimId: widget.claimId,
      emptyTitleMessage: l10n.claimTitleRequired,
      checklistLabels: widget.claimId != null
          ? const []
          : [
              l10n.checklistClaimForm,
              l10n.checklistOriginalBills,
              l10n.checklistPrescriptionCopy,
              l10n.checklistLabReports,
              l10n.checklistPolicyIdCopy,
            ],
    );
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    if (widget.claimId != null) {
      ref.watch(claimProvider(widget.claimId!));
      ref.watch(claimDocumentsProvider(widget.claimId!));
    }
    ref.watch(unclaimedBillsProvider);
    final policies =
        ref.watch(policiesProvider).value ?? const <InsurancePolicy>[];
    final documents =
        ref.watch(allDocumentsProvider).value ?? const <Document>[];
    _initialize();
    final state = ref.watch(claimEditControllerProvider);

    // Bills first (the usual attachments), then everything else.
    final ordered = [
      ...documents.where((d) => d.type == DocumentType.bill),
      ...documents.where((d) => d.type != DocumentType.bill),
    ];

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Text(
              widget.claimId == null ? l10n.claimNew : l10n.claimEdit,
              style: typo.pageTitle.copyWith(fontSize: 25),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              style: typo.body,
              onChanged: ref
                  .read(claimEditControllerProvider.notifier)
                  .setTitle,
              decoration: InputDecoration(
                labelText: l10n.claimTitleLabel,
                hintText: l10n.claimTitleHint,
              ),
            ),
            const SizedBox(height: 14),
            if (policies.isEmpty)
              Text(l10n.claimNoPolicyYet,
                  style: typo.caption.copyWith(color: colors.muted)),
            const SizedBox(height: 14),
            Text(l10n.claimPickDocuments, style: typo.cardTitle),
            Text(l10n.claimPickDocumentsSub,
                style: typo.caption.copyWith(color: colors.muted)),
            const SizedBox(height: 6),
            for (final doc in ordered)
              CheckboxListTile(
                value: state.selectedDocumentIds.contains(doc.id),
                onChanged: (_) => ref
                    .read(claimEditControllerProvider.notifier)
                    .toggleDocument(doc.id),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.body),
                subtitle: Text(
                  '${doc.type.localizedLabel(l10n)} · '
                  '${doc.documentDate.monthDay}',
                  style: typo.caption.copyWith(color: colors.muted),
                ),
              ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(state.error!,
                  style: typo.caption.copyWith(color: colors.amber)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: state.saving ? null : _save,
              child: Text(state.saving ? l10n.saving : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
```

(`date_format_x.dart` provides `.monthDay` — same extension `home_page.dart` uses.)

- [ ] **Step 5: Verify** — `flutter analyze && flutter test`; manual: Claims → New claim shows vault documents with unclaimed bills pre-checked; saving lands the claim in the list as Draft.

- [ ] **Step 6: Commit**

```bash
git add lib/features/claims/ test/features/claims/claim_edit_controller_test.dart
git commit -m "feat: add claim create/edit page with document picker"
```

---

### Task 11: Claim detail page — status actions, checklist

**Files:**
- Replace placeholder: `lib/features/claims/presentation/pages/claim_detail_page.dart`
- Create: `lib/features/claims/presentation/widgets/claim_checklist.dart`
- Test: `test/features/claims/claim_checklist_widget_test.dart`

**Interfaces:**
- Consumes: `claimProvider`, `claimDocumentsProvider`, `claimChecklistProvider`, `claimsRepositoryProvider`, `ClaimStatusL10n`, `formatPaise`/`parsePaise`, route `documentViewer` (`/home/documents/:id`).
- Produces: `ClaimChecklist({required List<ClaimChecklistItem> items, required void Function(ClaimChecklistItem, bool) onToggle, required ValueChanged<String> onAdd, required void Function(ClaimChecklistItem) onRemove})` — a pure widget, no providers, so it widget-tests directly.

- [ ] **Step 1: Write the failing widget test**

```dart
// test/features/claims/claim_checklist_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/claims/presentation/widgets/claim_checklist.dart';
import 'package:recora/l10n/app_localizations.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

ClaimChecklistItem _item(String id, String label, {bool done = false}) {
  return ClaimChecklistItem(
      id: id, claimId: 'c1', label: label, isDone: done, sortOrder: 0);
}

void main() {
  testWidgets('renders items with their done state and reports toggles',
      (tester) async {
    ClaimChecklistItem? toggled;
    bool? toggledTo;
    await tester.pumpWidget(_host(ClaimChecklist(
      items: [_item('i1', 'Claim form'), _item('i2', 'Bills', done: true)],
      onToggle: (item, done) {
        toggled = item;
        toggledTo = done;
      },
      onAdd: (_) {},
      onRemove: (_) {},
    )));

    expect(find.text('Claim form'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    expect(toggled!.id, 'i1');
    expect(toggledTo, isTrue);
  });

  testWidgets('typing a new item and submitting reports onAdd',
      (tester) async {
    String? added;
    await tester.pumpWidget(_host(ClaimChecklist(
      items: const [],
      onToggle: (_, _) {},
      onAdd: (label) => added = label,
      onRemove: (_) {},
    )));

    await tester.enterText(find.byType(TextField), 'Aadhaar copy');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(added, 'Aadhaar copy');
  });

  testWidgets('remove button reports the item', (tester) async {
    ClaimChecklistItem? removed;
    await tester.pumpWidget(_host(ClaimChecklist(
      items: [_item('i1', 'Claim form')],
      onToggle: (_, _) {},
      onAdd: (_) {},
      onRemove: (item) => removed = item,
    )));

    await tester.tap(find.byIcon(Icons.close));
    expect(removed!.id, 'i1');
  });
}
```

- [ ] **Step 2: Run to verify it fails**, then **build the checklist widget**:

```dart
// lib/features/claims/presentation/widgets/claim_checklist.dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// The claim's submission checklist: toggleable rows, inline add field,
/// per-row remove. Stateless over its callbacks so it tests in isolation.
class ClaimChecklist extends StatefulWidget {
  const ClaimChecklist({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ClaimChecklistItem> items;
  final void Function(ClaimChecklistItem item, bool isDone) onToggle;
  final ValueChanged<String> onAdd;
  final void Function(ClaimChecklistItem item) onRemove;

  @override
  State<ClaimChecklist> createState() => _ClaimChecklistState();
}

class _ClaimChecklistState extends State<ClaimChecklist> {
  final _add = TextEditingController();

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final label = value.trim();
    if (label.isEmpty) return;
    widget.onAdd(label);
    _add.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in widget.items)
          Row(
            children: [
              Checkbox(
                value: item.isDone,
                onChanged: (value) =>
                    widget.onToggle(item, value ?? false),
              ),
              Expanded(
                child: Text(
                  item.label,
                  style: typo.body.copyWith(
                    decoration:
                        item.isDone ? TextDecoration.lineThrough : null,
                    color: item.isDone ? colors.muted : colors.ink,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: colors.muted),
                onPressed: () => widget.onRemove(item),
              ),
            ],
          ),
        TextField(
          controller: _add,
          style: typo.body,
          textInputAction: TextInputAction.done,
          onSubmitted: _submit,
          decoration: InputDecoration(
            hintText: context.l10n.claimChecklistAddHint,
            prefixIcon: Icon(Icons.add, size: 18, color: colors.muted),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Run widget test** — expect PASS.

- [ ] **Step 4: Build the detail page** (replacing the Task 8 placeholder):

```dart
// lib/features/claims/presentation/pages/claim_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';
import '../../data/repository_impl/claims_repository_impl.dart';
import '../controllers/claims_providers.dart';
import '../widgets/claim_checklist.dart';

/// One claim: status trail, amounts, attached documents, checklist, and
/// the status-appropriate primary action.
class ClaimDetailPage extends ConsumerWidget {
  const ClaimDetailPage({super.key, required this.claimId});

  final String claimId;

  Future<void> _showResult(
      BuildContext context, Future<Result<void>> future) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await future;
    result.when(
      ok: (_) {},
      err: (failure) => messenger
          .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _markSubmitted(
      BuildContext context, WidgetRef ref, Claim claim) async {
    final entered = await showDialog<({int paise, String ref})>(
      context: context,
      builder: (_) => const _SubmitDialog(),
    );
    if (entered == null || !context.mounted) return;
    await _showResult(
      context,
      ref.read(claimsRepositoryProvider).markSubmitted(
            claimId: claim.id,
            submittedOn: DateTime.now(),
            claimedAmountPaise: entered.paise,
            insurerRef: entered.ref,
          ),
    );
  }

  Future<void> _recordOutcome(
      BuildContext context, WidgetRef ref, Claim claim) async {
    final entered = await showDialog<({ClaimStatus outcome, int? paise})>(
      context: context,
      builder: (_) =>
          _OutcomeDialog(claimedPaise: claim.claimedAmountPaise),
    );
    if (entered == null || !context.mounted) return;
    await _showResult(
      context,
      ref.read(claimsRepositoryProvider).recordOutcome(
            claimId: claim.id,
            outcome: entered.outcome,
            settledOn: DateTime.now(),
            approvedAmountPaise: entered.paise,
          ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Claim claim) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.claimDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.claimDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(claimsRepositoryProvider).deleteClaim(claim.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final claim = ref.watch(claimProvider(claimId)).value;
    final documents =
        ref.watch(claimDocumentsProvider(claimId)).value ?? const [];
    final checklist =
        ref.watch(claimChecklistProvider(claimId)).value ?? const [];

    if (claim == null) {
      return Scaffold(
        backgroundColor: colors.bgSection,
        appBar: AppBar(
            backgroundColor: colors.bgSection,
            leading: BackButton(color: colors.ink)),
        body: const SizedBox.shrink(),
      );
    }
    final repo = ref.read(claimsRepositoryProvider);

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
        actions: [
          if (claim.status == ClaimStatus.draft) ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colors.ink, size: 20),
              onPressed: () => context.pushNamed('claimEdit',
                  queryParameters: {'id': claim.id}),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: colors.ink, size: 20),
              onPressed: () => _delete(context, ref, claim),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Text(claim.title,
                style: typo.pageTitle.copyWith(fontSize: 25)),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(typo, colors, l10n.claimCreatedOn,
                      claim.createdAt.monthDay),
                  if (claim.submittedOn != null)
                    _line(typo, colors, l10n.claimSubmittedOn,
                        claim.submittedOn!.monthDay),
                  if (claim.settledOn != null)
                    _line(typo, colors, l10n.claimSettledOn,
                        claim.settledOn!.monthDay),
                  if (claim.claimedAmountPaise != null)
                    _line(typo, colors, l10n.claimAmountClaimed,
                        formatPaise(claim.claimedAmountPaise!)),
                  if (claim.approvedAmountPaise != null)
                    _line(typo, colors, l10n.claimAmountApproved,
                        formatPaise(claim.approvedAmountPaise!)),
                  if (claim.insurerRef.isNotEmpty)
                    _line(typo, colors, l10n.claimInsurerRefLabel,
                        claim.insurerRef),
                  _line(typo, colors, l10n.claimPolicyLabel,
                      claim.status.localizedLabel(l10n)),
                ],
              ),
            ),
            SectionHeader(title: l10n.claimDocumentsSection),
            for (final doc in documents)
              AppCard(
                onTap: () => context.pushNamed('documentViewer',
                    pathParameters: {'id': doc.id}),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 18, color: colors.muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(doc.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typo.body),
                    ),
                    Text(doc.documentDate.monthDay,
                        style:
                            typo.caption.copyWith(color: colors.muted)),
                  ],
                ),
              ),
            SectionHeader(title: l10n.claimChecklistSection),
            ClaimChecklist(
              items: checklist,
              onToggle: (item, done) => repo.setChecklistItemDone(
                  item.id, item.claimId, item.label, item.sortOrder, done),
              onAdd: (label) => repo.addChecklistItem(claim.id, label),
              onRemove: (item) => repo.removeChecklistItem(item.id),
            ),
            const SizedBox(height: 20),
            switch (claim.status) {
              ClaimStatus.draft => FilledButton(
                  onPressed: () => _markSubmitted(context, ref, claim),
                  child: Text(l10n.claimMarkSubmitted),
                ),
              ClaimStatus.submitted => FilledButton(
                  onPressed: () => _recordOutcome(context, ref, claim),
                  child: Text(l10n.claimRecordOutcome),
                ),
              ClaimStatus.rejected => OutlinedButton(
                  onPressed: () => _showResult(
                      context, repo.reopenAsDraft(claim.id)),
                  child: Text(l10n.claimReopen),
                ),
              _ => const SizedBox.shrink(),
            },
          ],
        ),
      ),
    );
  }

  Widget _line(
      AppTypography typo, AppColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: typo.caption.copyWith(color: colors.muted)),
          Text(value, style: typo.body),
        ],
      ),
    );
  }
}

/// Submission date is "now" by design; the dialog collects amount and the
/// insurer's claim number.
class _SubmitDialog extends StatefulWidget {
  const _SubmitDialog();

  @override
  State<_SubmitDialog> createState() => _SubmitDialogState();
}

class _SubmitDialogState extends State<_SubmitDialog> {
  final _amount = TextEditingController();
  final _ref = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _ref.dispose();
    super.dispose();
  }

  void _confirm() {
    final paise = parsePaise(_amount.text);
    if (paise == null) {
      setState(() => _error = context.l10n.claimAmountInvalid);
      return;
    }
    Navigator.pop(context, (paise: paise, ref: _ref.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo;
    return AlertDialog(
      title: Text(l10n.claimMarkSubmitted, style: typo.cardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: typo.body,
            decoration: InputDecoration(
              labelText: l10n.claimAmountClaimed,
              hintText: l10n.claimAmountHint,
              errorText: _error,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ref,
            style: typo.body,
            decoration:
                InputDecoration(labelText: l10n.claimInsurerRefLabel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(l10n.save)),
      ],
    );
  }
}

class _OutcomeDialog extends StatefulWidget {
  const _OutcomeDialog({required this.claimedPaise});

  final int? claimedPaise;

  @override
  State<_OutcomeDialog> createState() => _OutcomeDialogState();
}

class _OutcomeDialogState extends State<_OutcomeDialog> {
  final _amount = TextEditingController();
  ClaimStatus _outcome = ClaimStatus.approved;
  String? _error;
  String? _warning;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _confirm() {
    final l10n = context.l10n;
    int? paise;
    if (_outcome != ClaimStatus.rejected) {
      paise = parsePaise(_amount.text);
      if (paise == null) {
        setState(() => _error = l10n.claimAmountInvalid);
        return;
      }
      // Warn, don't block — partial settlements have quirky math.
      final claimed = widget.claimedPaise;
      if (claimed != null && paise > claimed && _warning == null) {
        setState(() => _warning = l10n.claimApprovedExceedsWarning);
        return;
      }
    }
    Navigator.pop(context, (outcome: _outcome, paise: paise));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo;
    final colors = context.colors;
    return AlertDialog(
      title: Text(l10n.claimRecordOutcome, style: typo.cardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (outcome, label) in [
            (ClaimStatus.approved, l10n.claimOutcomeApproved),
            (ClaimStatus.partiallySettled, l10n.claimOutcomePartial),
            (ClaimStatus.rejected, l10n.claimOutcomeRejected),
          ])
            RadioListTile<ClaimStatus>(
              value: outcome,
              groupValue: _outcome,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: typo.body),
              onChanged: (value) =>
                  setState(() => _outcome = value ?? _outcome),
            ),
          if (_outcome != ClaimStatus.rejected)
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              style: typo.body,
              decoration: InputDecoration(
                labelText: l10n.claimAmountApproved,
                hintText: l10n.claimAmountHint,
                errorText: _error,
              ),
            ),
          if (_warning != null) ...[
            const SizedBox(height: 8),
            Text(_warning!,
                style: typo.caption.copyWith(color: colors.amber)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(l10n.save)),
      ],
    );
  }
}
```

Note the `documentViewer` route lives under `/home/documents/:id` — `pushNamed('documentViewer', pathParameters: {'id': doc.id})` works from the root navigator because names resolve globally.

- [ ] **Step 5: Verify** — `flutter analyze && flutter test`; manual on emulator: draft → Mark submitted (amount ₹12,400) → Record outcome (partial, ₹11,100); timeline shows both events; rejected → Reopen works.

- [ ] **Step 6: Commit**

```bash
git add lib/features/claims/ test/features/claims/claim_checklist_widget_test.dart
git commit -m "feat: add claim detail page with lifecycle actions and checklist"
```

---

### Task 12: Deadline notifications

**Files:**
- Modify: `lib/core/services/reminder_service.dart`
- Test: extend `test/shared/claim_deadlines_test.dart` (already covers the planner — this task is wiring)

**Interfaces:**
- Consumes: `planBillReminders` / `BillReminder` (Task 2), `db.claimDao.watchUnclaimedBills()`, `db.claimDao.watchPolicies()`.
- Produces: `ReminderService.sync` gains `required List<BillReminder> billReminders`.

- [ ] **Step 1: Add the claims channel and parameter to `ReminderService`**

Add next to the other channels:

```dart
  static const _claimChannel = AndroidNotificationDetails(
    'claims',
    'Insurance claim reminders',
    channelDescription:
        'A reminder before an unclaimed bill passes its claim window',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
```

Extend `sync` with `required List<BillReminder> billReminders,` and, after the dialysis block inside the try:

```dart
      for (final reminder in billReminders) {
        if (!reminder.at.isAfter(now)) continue;
        await _schedule(
          id: reminder.id,
          at: reminder.at,
          title: 'Bill not claimed yet — ${reminder.billTitle}',
          body: '${reminder.daysLeft} days left in the claim window. '
              'Attach it to a claim in KidneyCare.',
          details: const NotificationDetails(android: _claimChannel),
        );
      }
```

Add `import '../../shared/domain/claim_deadlines.dart';`.

- [ ] **Step 2: Wire the providers**

In the same file add below `_nextSessionProvider`:

```dart
final _unclaimedBillsForRemindersProvider =
    StreamProvider<List<Document>>((ref) {
  return ref.watch(databaseProvider).claimDao.watchUnclaimedBills();
});

final _policiesForRemindersProvider =
    StreamProvider<List<InsurancePolicy>>((ref) {
  return ref.watch(databaseProvider).claimDao.watchPolicies();
});
```

and extend `reminderSyncProvider`:

```dart
final reminderSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(remindersEnabledProvider);
  final doses = ref.watch(_todaysDosesProvider).value ?? const <Dose>[];
  final next = ref.watch(_nextSessionProvider).value;
  final bills =
      ref.watch(_unclaimedBillsForRemindersProvider).value ?? const [];
  final policies =
      ref.watch(_policiesForRemindersProvider).value ?? const [];
  final billReminders = policies.isEmpty
      ? const <BillReminder>[]
      : planBillReminders(
          bills: [
            for (final bill in bills)
              (title: bill.title, date: bill.documentDate),
          ],
          windowDays: policies.first.claimWindowDays,
          now: DateTime.now(),
        );
  Future.microtask(() => ref.read(reminderServiceProvider).sync(
        enabled: enabled,
        todaysDoses: doses,
        nextSession: next,
        billReminders: billReminders,
      ));
});
```

- [ ] **Step 3: Fix every other `sync` call site**

Run: `flutter analyze` — it lists any caller missing `billReminders`; pass `billReminders: const []` only in tests, and the real plan everywhere else (the app has a single call site in `reminderSyncProvider`).

- [ ] **Step 4: Verify** — `flutter analyze && flutter test`. Manual: with a policy saved and an old unclaimed bill, a scheduled notification appears in `adb shell dumpsys notification --noredact | grep -A2 claims` (or simply: attach the bill to a claim and confirm no claim notification fires next sync).

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/reminder_service.dart
git commit -m "feat: schedule claim-window reminders for unclaimed bills"
```

---

### Task 13: Home claims glance card

**Files:**
- Create: `lib/features/claims/presentation/widgets/claims_glance_card.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`

**Interfaces:**
- Consumes: `unclaimedBillsProvider`, `claimsListProvider`, `policiesProvider`, `staleSubmitted`, `daysUntilDeadline`, route name `claims`.
- Produces: `ClaimsGlanceCard()` — renders `SizedBox.shrink()` when nothing needs action (Home stays calm).

- [ ] **Step 1: Build the widget**

```dart
// lib/features/claims/presentation/widgets/claims_glance_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/claim_deadlines.dart';
import '../controllers/claims_providers.dart';

/// Home's claims nudge: bills whose claim window is closing (≤ 7 days)
/// and submitted claims waiting > 30 days. Invisible when neither exists.
class ClaimsGlanceCard extends ConsumerWidget {
  const ClaimsGlanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final now = DateTime.now();

    final bills =
        ref.watch(unclaimedBillsProvider).value ?? const <Document>[];
    final claims = ref.watch(claimsListProvider).value ?? const <Claim>[];
    final policies =
        ref.watch(policiesProvider).value ?? const <InsurancePolicy>[];

    final expiring = policies.isEmpty
        ? const <Document>[]
        : bills
            .where((b) =>
                daysUntilDeadline(b.documentDate,
                    policies.first.claimWindowDays, now) <=
                7)
            .toList();
    final stale = staleSubmitted(claims, now);

    final lines = <String>[
      for (final bill in expiring.take(2))
        switch (daysUntilDeadline(
            bill.documentDate, policies.first.claimWindowDays, now)) {
          < 0 => '${bill.title} — ${l10n.claimOverdue}',
          final days => '${bill.title} — ${l10n.claimDaysLeft(days)}',
        },
      for (final claim in stale.take(2))
        '${claim.title} — '
            '${l10n.claimAwaitingLong(now.difference(claim.submittedOn!).inDays)}',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.pushNamed('claims'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.amberBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.amberBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.claimGlanceTitle(lines.length),
              style:
                  typo.overline.copyWith(fontSize: 11, color: colors.amber),
            ),
            for (final line in lines) ...[
              const SizedBox(height: 5),
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typo.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: colors.ink.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Place it on Home** — in `home_page.dart` add the import and insert `const ClaimsGlanceCard(),` directly after `const QuickActionsRow(),`.

- [ ] **Step 3: Verify** — `flutter analyze && flutter test`; manual: with an expiring unclaimed bill the card shows and taps through to Claims; with none, Home is unchanged.

- [ ] **Step 4: Commit**

```bash
git add lib/features/claims/presentation/widgets/claims_glance_card.dart lib/features/home/presentation/pages/home_page.dart
git commit -m "feat: add claims glance card to home"
```

---

### Task 14: Full verification and release to the emulator

**Files:** none new (fixes only if verification finds problems).

- [ ] **Step 1: Full static + test pass**

```bash
flutter analyze && flutter test
```

Expected: zero analyzer issues; every test green (32 pre-existing + all new).

- [ ] **Step 2: BACK UP THE REAL VAULT before installing**

The emulator holds the father's live medical data and this build runs a schema migration on it. In the running app: Settings → Export backup, and save the shared JSON off-device. Do not skip this.

- [ ] **Step 3: Build and install**

```bash
flutter build apk --debug
MSYS_NO_PATHCONV=1 adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Expected: installs over the existing app; app opens with all existing data intact (migration is additive).

- [ ] **Step 4: Manual QA script on the emulator**

1. Settings → Insurance policy → save insurer/number/window 30.
2. Home → Claims chip → empty state shows.
3. New claim → unclaimed bills pre-checked → save → appears as Draft.
4. Detail → checklist toggles persist across back-and-forth.
5. Mark submitted with ₹ amount → status chip flips, timeline event on Home's recent records.
6. Record outcome (partial) → YTD strip on Claims page shows claimed/recovered.
7. Language → हिन्दी → Claims screens read naturally.
8. Reminders: keep one unclaimed bill dated ~26 days ago → a "Bill not claimed yet" notification is scheduled (verify via `adb shell dumpsys notification`); attach the bill to a claim → next sync drops it.

- [ ] **Step 5: Update project docs**

Add a Claims bullet under "Features built" in `MEMORY.md` (schema now v6; note `drift_schemas/` must be kept for future migration tests). MEMORY.md is gitignored — no commit needed for it.

- [ ] **Step 6: Final commit and push**

```bash
git add -A && git status   # confirm only intended files
git commit -m "feat: insurance claims tracking (spec 2026-08-15)"
git push
```

---

## Self-review (completed at plan-writing time)

- **Spec coverage:** data model → Tasks 3–4; lifecycle/amounts/checklist rules → Task 6; claims list/YTD/unclaimed chip → Task 8; detail + actions + checklist → Task 11; new/edit + picker → Task 10; policy editor in Settings → Task 9; deadline reminders → Tasks 2 + 12; Home entry + glance triggers → Tasks 8 + 13; timeline events → Tasks 5–6; l10n → Task 5; migration test → Task 3; widget test → Task 11. No spec requirement is left untasked.
- **Type consistency:** `billReminders`/`BillReminder`, `claimedAmountPaise`/`approvedAmountPaise`, provider names, and route names (`claims`, `claimEdit`, `claimDetail`, `policyEdit`) are used identically across tasks.
- **Known judgment calls (executor: do not "fix" these):** submission/settlement dates default to "now" via the dialogs (caregivers log same-day; edit later is out of scope). The approved-greater-than-claimed check warns once in the dialog then allows. Demo seed is intentionally untouched.
