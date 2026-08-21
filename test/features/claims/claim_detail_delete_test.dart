import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/storage/database_provider.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/claims/presentation/pages/claim_detail_page.dart';
import 'package:recora/l10n/app_localizations.dart';
import 'package:recora/shared/domain/claim_status.dart';

Widget _host(AppDatabase db, String claimId) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ClaimDetailPage(claimId: claimId),
    ),
  );
}

/// Flush drift's async stream-teardown callbacks before the framework
/// checks for pending timers.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seedClaim(
    WidgetTester tester,
    ClaimStatus status,
  ) async {
    // Drift resolves its futures on real-time timers, so the seed data
    // must be written outside the widget test's fake clock.
    await tester.runAsync(() => db.claimDao.upsertClaim(ClaimsCompanion(
          id: const Value('c1'),
          title: const Value('August dialysis'),
          status: Value(status),
          createdAt: Value(DateTime(2026, 8, 1)),
          submittedOn: status == ClaimStatus.draft
              ? const Value(null)
              : Value(DateTime(2026, 8, 3)),
          settledOn: status.isOutcome
              ? Value(DateTime(2026, 8, 10))
              : const Value(null),
          claimedAmountPaise: status == ClaimStatus.draft
              ? const Value(null)
              : const Value(1240000),
        )));
  }

  testWidgets('a settled claim offers delete with the totals warning',
      (tester) async {
    await seedClaim(tester, ClaimStatus.approved);
    await tester.pumpWidget(_host(db, 'c1'));
    await tester.pumpAndSettle();

    // Deletable but no longer editable.
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(
      find.textContaining("no longer count in this year's totals"),
      findsOneWidget,
    );

    await _unmount(tester);
  });

  testWidgets('a claim with the insurer cannot be deleted', (tester) async {
    await seedClaim(tester, ClaimStatus.submitted);
    await tester.pumpWidget(_host(db, 'c1'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);

    await _unmount(tester);
  });

  testWidgets('a draft keeps edit and delete with the lighter warning',
      (tester) async {
    await seedClaim(tester, ClaimStatus.draft);
    await tester.pumpWidget(_host(db, 'c1'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(
      find.text('Delete this claim? Its documents stay in the vault.'),
      findsOneWidget,
    );

    await _unmount(tester);
  });
}
