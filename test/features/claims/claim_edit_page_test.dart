import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/storage/database_provider.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/claims/presentation/pages/claim_edit_page.dart';
import 'package:recora/l10n/app_localizations.dart';
import 'package:recora/shared/domain/claim_status.dart';
import 'package:recora/shared/domain/document_type.dart';

GoRouter _router() => GoRouter(
      initialLocation: '/base',
      routes: [
        GoRoute(
          path: '/base',
          name: 'base',
          builder: (context, state) => const Scaffold(body: Text('base')),
        ),
        GoRoute(
          path: '/claim-edit',
          name: 'claimEdit',
          builder: (context, state) => ClaimEditPage(
            claimId: state.uri.queryParameters['id'],
          ),
        ),
      ],
    );

Widget _host(AppDatabase db, GoRouter router) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp.router(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

/// Pumps the app at `/base` then pushes the claim editor on top, the same
/// way the FAB on the claims list does via `context.pushNamed('claimEdit')`.
Future<GoRouter> _pumpToClaimEditor(WidgetTester tester, AppDatabase db,
    {String? claimId}) async {
  final router = _router();
  await tester.pumpWidget(_host(db, router));
  await tester.pumpAndSettle();
  unawaited(router.pushNamed(
    'claimEdit',
    queryParameters: claimId == null ? {} : {'id': claimId},
  ));
  await tester.pumpAndSettle();
  return router;
}

/// See policy_edit_page_test.dart: flushes drift's async stream-query
/// cancellation so flutter_test's pending-timer check doesn't trip.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> addPolicy(String id, String insurer, String number) {
    return db.claimDao.upsertPolicy(InsurancePoliciesCompanion.insert(
      id: id,
      insurerName: insurer,
      policyNumber: number,
    ));
  }

  Future<void> addDraftClaim(String id, String title, {String? policyId}) {
    return db.claimDao.upsertClaim(ClaimsCompanion.insert(
      id: id,
      policyId: policyId == null ? const Value.absent() : Value(policyId),
      title: title,
      status: ClaimStatus.draft,
      createdAt: DateTime(2026, 8, 1),
    ));
  }

  Future<void> addBill(String id) {
    return db.documentDao.upsert(DocumentsCompanion(
      id: Value(id),
      type: const Value(DocumentType.bill),
      title: Value('Bill $id'),
      documentDate: Value(DateTime(2026, 8, 1)),
      capturedAt: Value(DateTime(2026, 8, 1)),
    ));
  }

  testWidgets(
      'two policies: dropdown lists both and saving persists the chosen policyId',
      (tester) async {
    await addPolicy('p1', 'Star Health', 'POL-1');
    await addPolicy('p2', 'HDFC Ergo', 'POL-2');

    await _pumpToClaimEditor(tester, db);

    await tester.enterText(
        find.widgetWithText(TextField, 'Claim title'), 'August bundle');

    // Nothing is auto-selected with two policies on hand.
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    expect(find.text('Star Health · POL-1'), findsOneWidget);
    expect(find.text('HDFC Ergo · POL-2'), findsOneWidget);

    await tester.tap(find.text('HDFC Ergo · POL-2'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final claims = await db.select(db.claims).get();
    expect(claims, hasLength(1));
    expect(claims.first.policyId, 'p2');
    expect(find.text('base'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets(
      'unclaimed bill is pre-checked on create and saving persists the link',
      (tester) async {
    await addBill('bill-1');

    await _pumpToClaimEditor(tester, db);

    final checkbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Bill bill-1'));
    expect(checkbox.value, isTrue);

    await tester.enterText(
        find.widgetWithText(TextField, 'Claim title'), 'August bundle');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final claims = await db.select(db.claims).get();
    expect(claims, hasLength(1));
    final links = await db.select(db.claimDocuments).get();
    expect(links, hasLength(1));
    expect(links.first.documentId, 'bill-1');
    expect(links.first.claimId, claims.first.id);
    await _unmount(tester);
  });

  testWidgets(
      'editing a claim with no linked policy shows "none" selected even '
      'when exactly one policy now exists, and choosing it persists the link',
      (tester) async {
    await addPolicy('p1', 'Star Health', 'POL-1');
    await addDraftClaim('c1', 'August bundle', policyId: null);

    await _pumpToClaimEditor(tester, db, claimId: 'c1');

    // The dropdown must show "none" — never silently the sole policy —
    // because the claim's stored policyId is actually null.
    expect(find.text('No policy'), findsOneWidget);
    expect(find.text('Star Health · POL-1'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Star Health · POL-1'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final claim = await (db.select(db.claims)
          ..where((c) => c.id.equals('c1')))
        .getSingle();
    expect(claim.policyId, 'p1');
    expect(find.text('base'), findsOneWidget);
    await _unmount(tester);
  });
}
