import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/claims/presentation/widgets/claim_card.dart';
import 'package:recora/l10n/app_localizations.dart';
import 'package:recora/shared/domain/claim_status.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

Claim _claim({
  required ClaimStatus status,
  DateTime? submittedOn,
  DateTime? settledOn,
  int? claimedPaise,
  int? approvedPaise,
}) {
  return Claim(
    id: 'c1',
    policyId: null,
    title: 'August dialysis and medicines',
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

void main() {
  testWidgets('draft claim shows title, doc count, date — no money line',
      (tester) async {
    await tester.pumpWidget(_host(ClaimCard(
      claim: _claim(status: ClaimStatus.draft),
      docCount: 2,
    )));

    expect(find.text('August dialysis and medicines'), findsOneWidget);
    expect(find.text('Getting ready'), findsOneWidget);
    expect(find.textContaining('2 documents'), findsOneWidget);
    expect(find.textContaining('Claimed'), findsNothing);
    expect(find.textContaining('recovered'), findsNothing);
  });

  testWidgets('submitted claim with a claimed amount shows the money line',
      (tester) async {
    await tester.pumpWidget(_host(ClaimCard(
      claim: _claim(
        status: ClaimStatus.submitted,
        submittedOn: DateTime(2026, 8, 3),
        claimedPaise: 1240000,
      ),
      docCount: 3,
    )));

    expect(find.text('With insurer'), findsOneWidget);
    expect(
        find.text('Claimed ₹12,400 · waiting on insurer'), findsOneWidget);
  });

  testWidgets('approved claim shows what came back', (tester) async {
    await tester.pumpWidget(_host(ClaimCard(
      claim: _claim(
        status: ClaimStatus.approved,
        submittedOn: DateTime(2026, 8, 3),
        settledOn: DateTime(2026, 8, 10),
        claimedPaise: 1240000,
        approvedPaise: 1000000,
      ),
      docCount: 3,
    )));

    expect(find.text('Paid in full'), findsOneWidget);
    expect(find.text('₹10,000 recovered'), findsOneWidget);
    expect(find.textContaining('Claimed'), findsNothing);
  });

  testWidgets('partly paid claim shows recovered against claimed',
      (tester) async {
    await tester.pumpWidget(_host(ClaimCard(
      claim: _claim(
        status: ClaimStatus.partiallySettled,
        submittedOn: DateTime(2026, 8, 3),
        settledOn: DateTime(2026, 8, 10),
        claimedPaise: 1240000,
        approvedPaise: 1000000,
      ),
      docCount: 3,
    )));

    expect(find.text('Partly paid'), findsOneWidget);
    expect(find.text('₹10,000 of ₹12,400 recovered'), findsOneWidget);
  });

  testWidgets('rejected claim says nothing was paid', (tester) async {
    await tester.pumpWidget(_host(ClaimCard(
      claim: _claim(
        status: ClaimStatus.rejected,
        submittedOn: DateTime(2026, 8, 3),
        settledOn: DateTime(2026, 8, 10),
        claimedPaise: 1240000,
      ),
      docCount: 3,
    )));

    expect(find.text('Rejected'), findsOneWidget);
    expect(find.text('₹12,400 claimed · nothing paid'), findsOneWidget);
  });

  testWidgets('tapping the card reports the tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(ClaimCard(
      claim: _claim(status: ClaimStatus.draft),
      docCount: 0,
      onTap: () => tapped = true,
    )));

    await tester.tap(find.byType(ClaimCard));
    expect(tapped, isTrue);
  });
}
