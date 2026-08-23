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

  Future<void> seedDraft(WidgetTester tester) async {
    // Drift resolves its futures on real-time timers, so the seed data
    // must be written outside the widget test's fake clock.
    await tester.runAsync(() => db.claimDao.upsertClaim(ClaimsCompanion(
          id: const Value('c1'),
          title: const Value('Small pharmacy claim'),
          status: const Value(ClaimStatus.draft),
          createdAt: Value(DateTime(2026, 8, 1)),
        )));
  }

  testWidgets('a documentless draft shows the empty state', (tester) async {
    await seedDraft(tester);
    await tester.pumpWidget(_host(db, 'c1'));
    await tester.pumpAndSettle();

    expect(find.text('No documents attached'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('a documentless draft can be marked submitted', (tester) async {
    await seedDraft(tester);
    await tester.pumpWidget(_host(db, 'c1'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Mark submitted'));
    await tester.pumpAndSettle();

    // The submit dialog opens instead of the old "attach a document" snackbar.
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await _unmount(tester);
  });
}
