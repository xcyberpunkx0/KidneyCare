import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/claims/presentation/controllers/claims_providers.dart';
import 'package:recora/features/claims/presentation/pages/claims_page.dart';
import 'package:recora/l10n/app_localizations.dart';
import 'package:recora/shared/domain/claim_status.dart';
import 'package:recora/shared/domain/document_type.dart';

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
    createdAt: DateTime(2026, 8, 1),
    submittedOn: submittedOn,
    settledOn: settledOn,
    claimedAmountPaise: claimedPaise,
    approvedAmountPaise: approvedPaise,
    insurerRef: '',
    note: '',
  );
}

InsurancePolicy _policy(String id, {required int claimWindowDays}) {
  return InsurancePolicy(
    id: id,
    insurerName: 'Insurer $id',
    policyNumber: id,
    tpaName: '',
    claimWindowDays: claimWindowDays,
    note: '',
  );
}

Document _bill(String id, {DateTime? documentDate}) {
  return Document(
    id: id,
    type: DocumentType.bill,
    title: id,
    hospital: '',
    doctor: '',
    documentDate: documentDate ?? DateTime(2026, 8, 1),
    capturedAt: DateTime(2026, 8, 1),
    originalPath: '',
    previewPath: '',
    ocrText: '',
    tagsJson: '[]',
    note: '',
  );
}

Widget _host({
  required List<Claim> claims,
  List<ClaimDocument> links = const [],
  List<Document> unclaimed = const [],
  List<InsurancePolicy> policies = const [],
  void Function(String name)? onPush,
}) {
  final router = GoRouter(
    initialLocation: '/claims',
    routes: [
      GoRoute(
        path: '/claims',
        name: 'claims',
        builder: (context, state) => const ClaimsPage(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'claimEdit',
            builder: (context, state) {
              onPush?.call('claimEdit');
              return const Scaffold(body: Text('edit-page'));
            },
          ),
          GoRoute(
            path: ':id',
            name: 'claimDetail',
            builder: (context, state) {
              onPush?.call('claimDetail');
              return Scaffold(
                body: Text('detail-${state.pathParameters['id']}'),
              );
            },
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      claimsListProvider.overrideWith((ref) => Stream.value(claims)),
      claimLinksProvider.overrideWith((ref) => Stream.value(links)),
      unclaimedBillsProvider.overrideWith((ref) => Stream.value(unclaimed)),
      policiesProvider.overrideWith((ref) => Stream.value(policies)),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('empty claims and no unclaimed bills shows the empty state',
      (tester) async {
    await tester.pumpWidget(_host(claims: const []));
    await tester.pumpAndSettle();

    expect(find.text('No claims yet'), findsOneWidget);
  });

  testWidgets('claims are grouped into attention / in-progress / history',
      (tester) async {
    final claims = [
      _claim(id: 'draft-1', status: ClaimStatus.draft),
      _claim(
        id: 'submitted-1',
        status: ClaimStatus.submitted,
        submittedOn: DateTime(2026, 8, 10),
      ),
      _claim(
        id: 'approved-1',
        status: ClaimStatus.approved,
        submittedOn: DateTime(2026, 7, 1),
        settledOn: DateTime(2026, 7, 15),
      ),
    ];
    await tester.pumpWidget(_host(claims: claims));
    await tester.pumpAndSettle();

    expect(find.text('Needs your attention'), findsOneWidget);
    expect(find.text('Waiting for the insurer'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('draft-1'), findsOneWidget);
    expect(find.text('submitted-1'), findsOneWidget);
    expect(find.text('approved-1'), findsOneWidget);
  });

  testWidgets('the YTD summary card shows claimed and recovered totals',
      (tester) async {
    await tester.pumpWidget(_host(claims: [
      _claim(
        id: 'approved-1',
        status: ClaimStatus.approved,
        submittedOn: DateTime.now(),
        settledOn: DateTime.now(),
        claimedPaise: 1240000,
        approvedPaise: 1000000,
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Claimed this year'), findsOneWidget);
    expect(find.text('Recovered this year'), findsOneWidget);
    expect(find.text('₹12,400'), findsOneWidget);
    // ₹10,000 appears in the summary card and on the claim's own card.
    expect(find.textContaining('₹10,000'), findsWidgets);
  });

  testWidgets('unclaimed bills render the amber strip', (tester) async {
    await tester.pumpWidget(_host(
      claims: const [],
      unclaimed: [_bill('bill-1')],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('unclaimed'), findsOneWidget);
    expect(find.text('bill-1'), findsOneWidget);
  });

  testWidgets(
      'unclaimed strip uses the shortest policy window, not the first one',
      (tester) async {
    final now = DateTime.now();
    // With the 30-day policy alone the bill would still have 14 days left;
    // the 15-day policy (listed second) puts it 1 day past its deadline.
    // The strip must agree with Home/notifications and use the minimum.
    final billDate = now.subtract(const Duration(days: 16));
    await tester.pumpWidget(_host(
      claims: const [],
      unclaimed: [_bill('bill-1', documentDate: billDate)],
      policies: [
        _policy('p-long', claimWindowDays: 30),
        _policy('p-short', claimWindowDays: 15),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('bill-1'), findsOneWidget);
    expect(find.textContaining('Past claim window'), findsOneWidget);
    expect(find.textContaining('left to claim'), findsNothing);
  });

  testWidgets('tapping the FAB navigates to claimEdit', (tester) async {
    await tester.pumpWidget(_host(claims: const []));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('edit-page'), findsOneWidget);
  });

  testWidgets('tapping a claim card navigates to claimDetail with its id',
      (tester) async {
    await tester.pumpWidget(_host(
      claims: [_claim(id: 'draft-1', status: ClaimStatus.draft)],
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('draft-1'));
    await tester.pumpAndSettle();

    expect(find.text('detail-draft-1'), findsOneWidget);
  });
}
