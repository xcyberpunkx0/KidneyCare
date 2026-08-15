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
import 'package:recora/features/claims/presentation/pages/policy_edit_page.dart';
import 'package:recora/l10n/app_localizations.dart';

GoRouter _router() => GoRouter(
      initialLocation: '/base',
      routes: [
        GoRoute(
          path: '/base',
          name: 'base',
          builder: (context, state) => const Scaffold(body: Text('base')),
        ),
        GoRoute(
          path: '/policy',
          name: 'policyEdit',
          builder: (context, state) => const PolicyEditPage(),
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

/// Pumps the app at `/base` then pushes the policy editor on top, the
/// same way the Settings tile does via `context.pushNamed('policyEdit')`.
Future<GoRouter> _pumpToPolicyEditor(WidgetTester tester, AppDatabase db) async {
  final router = _router();
  await tester.pumpWidget(_host(db, router));
  await tester.pumpAndSettle();
  unawaited(router.pushNamed('policyEdit'));
  await tester.pumpAndSettle();
  return router;
}

/// Unmounting schedules an async cancellation callback on drift's stream
/// query store; flush it inside the test body so flutter_test's "no
/// pending timers" invariant doesn't trip once the framework tears down
/// the widget tree after the test returns.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('defaults the claim window to 30 days when there is no policy',
      (tester) async {
    await _pumpToPolicyEditor(tester, db);

    expect(find.widgetWithText(TextField, '30'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('saving with empty insurer shows the required error',
      (tester) async {
    await _pumpToPolicyEditor(tester, db);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Insurer and policy number are required.'),
      findsOneWidget,
    );
    await _unmount(tester);
  });

  testWidgets('saving with a non-positive window shows the window error',
      (tester) async {
    await _pumpToPolicyEditor(tester, db);

    await tester.enterText(
        find.widgetWithText(TextField, 'Insurer'), 'Star Health');
    await tester.enterText(
        find.widgetWithText(TextField, 'Policy number'), 'POL-1');
    await tester.enterText(
        find.widgetWithText(TextField, 'Claim window (days)'), '0');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter the number of days bills stay claimable.'),
      findsOneWidget,
    );
    await _unmount(tester);
  });

  testWidgets('saving a valid policy persists it and pops back to the caller',
      (tester) async {
    await _pumpToPolicyEditor(tester, db);

    await tester.enterText(
        find.widgetWithText(TextField, 'Insurer'), 'Star Health');
    await tester.enterText(
        find.widgetWithText(TextField, 'Policy number'), 'POL-1');
    await tester.enterText(
        find.widgetWithText(TextField, 'TPA (optional)'), 'MediAssist');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final policies = await db.select(db.insurancePolicies).get();
    expect(policies, hasLength(1));
    expect(policies.first.insurerName, 'Star Health');
    expect(policies.first.policyNumber, 'POL-1');
    expect(policies.first.tpaName, 'MediAssist');
    expect(policies.first.claimWindowDays, 30);
    expect(find.text('base'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Insurer'), findsNothing);
    await _unmount(tester);
  });

  testWidgets('reopening a saved policy prefills the form', (tester) async {
    await db.claimDao.upsertPolicy(InsurancePoliciesCompanion.insert(
      id: 'p1',
      insurerName: 'Star Health',
      policyNumber: 'POL-1',
      tpaName: const Value('MediAssist'),
      claimWindowDays: const Value(45),
    ));

    await _pumpToPolicyEditor(tester, db);

    expect(find.widgetWithText(TextField, 'Star Health'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'POL-1'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'MediAssist'), findsOneWidget);
    expect(find.widgetWithText(TextField, '45'), findsOneWidget);
    await _unmount(tester);
  });
}
