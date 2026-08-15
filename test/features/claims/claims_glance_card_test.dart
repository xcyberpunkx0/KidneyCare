import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/claims/presentation/controllers/claims_providers.dart';
import 'package:recora/features/claims/presentation/widgets/claims_glance_card.dart';
import 'package:recora/l10n/app_localizations.dart';
import 'package:recora/shared/domain/claim_status.dart';
import 'package:recora/shared/domain/document_type.dart';

Claim _claim({
  required String id,
  required ClaimStatus status,
  DateTime? submittedOn,
}) {
  return Claim(
    id: id,
    policyId: null,
    title: id,
    status: status,
    createdAt: DateTime(2026, 1, 1),
    submittedOn: submittedOn,
    settledOn: null,
    claimedAmountPaise: null,
    approvedAmountPaise: null,
    insurerRef: '',
    note: '',
  );
}

Document _bill(String id, {required DateTime documentDate}) {
  return Document(
    id: id,
    type: DocumentType.bill,
    title: id,
    hospital: '',
    doctor: '',
    documentDate: documentDate,
    capturedAt: documentDate,
    originalPath: '',
    previewPath: '',
    ocrText: '',
    tagsJson: '[]',
    note: '',
  );
}

InsurancePolicy _policy({int claimWindowDays = 30}) {
  return InsurancePolicy(
    id: 'p1',
    insurerName: 'Acme',
    policyNumber: '123',
    tpaName: '',
    claimWindowDays: claimWindowDays,
    note: '',
  );
}

Widget _host({
  List<Claim> claims = const [],
  List<Document> unclaimed = const [],
  List<InsurancePolicy> policies = const [],
  void Function()? onClaimsPush,
}) {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const Scaffold(body: ClaimsGlanceCard()),
      ),
      GoRoute(
        path: '/claims',
        name: 'claims',
        builder: (context, state) {
          onClaimsPush?.call();
          return const Scaffold(body: Text('claims-page'));
        },
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      claimsListProvider.overrideWith((ref) => Stream.value(claims)),
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
  testWidgets('renders nothing when there is nothing to act on',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byType(ClaimsGlanceCard), findsOneWidget);
    expect(find.byType(Container), findsNothing);
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('renders nothing when policies are empty even with bills',
      (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(_host(
      unclaimed: [_bill('bill-1', documentDate: now)],
      policies: const [],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsNothing);
  });

  testWidgets('shows an expiring bill within 7 days of its deadline',
      (tester) async {
    final now = DateTime.now();
    // billDate + 30 days ≈ now + 5 days: inside the 7-day window.
    final billDate = now.subtract(const Duration(days: 25));
    await tester.pumpWidget(_host(
      unclaimed: [_bill('Apollo bill', documentDate: billDate)],
      policies: [_policy(claimWindowDays: 30)],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Apollo bill'), findsOneWidget);
    expect(find.textContaining('left to claim'), findsOneWidget);
    expect(find.text('CLAIMS · 1'), findsOneWidget);
  });

  testWidgets('shows an overdue bill past its claim window', (tester) async {
    final now = DateTime.now();
    // billDate + 30 days ≈ now - 5 days: already overdue.
    final billDate = now.subtract(const Duration(days: 35));
    await tester.pumpWidget(_host(
      unclaimed: [_bill('Overdue bill', documentDate: billDate)],
      policies: [_policy(claimWindowDays: 30)],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Overdue bill'), findsOneWidget);
    expect(find.textContaining('Past claim window'), findsOneWidget);
  });

  testWidgets('does not surface a bill whose deadline is far away',
      (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(_host(
      unclaimed: [_bill('Fresh bill', documentDate: now)],
      policies: [_policy(claimWindowDays: 30)],
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Container), findsNothing);
  });

  testWidgets('shows a claim submitted more than 30 days ago',
      (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(_host(
      claims: [
        _claim(
          id: 'August dialysis',
          status: ClaimStatus.submitted,
          submittedOn: now.subtract(const Duration(days: 35)),
        ),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('August dialysis'), findsOneWidget);
    expect(find.textContaining('worth a follow-up call'), findsOneWidget);
  });

  testWidgets('tapping the card navigates to the claims route',
      (tester) async {
    var pushed = false;
    final now = DateTime.now();
    await tester.pumpWidget(_host(
      claims: [
        _claim(
          id: 'August dialysis',
          status: ClaimStatus.submitted,
          submittedOn: now.subtract(const Duration(days: 35)),
        ),
      ],
      onClaimsPush: () => pushed = true,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();

    expect(pushed, isTrue);
    expect(find.text('claims-page'), findsOneWidget);
  });
}
