import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/storage/database_provider.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/dialysis/data/repository_impl/dialysis_repository_impl.dart';
import 'package:recora/features/dialysis/domain/entities/session_log.dart';
import 'package:recora/features/dialysis/presentation/pages/dialysis_page.dart';
import 'package:recora/features/medications/data/repository_impl/medications_repository_impl.dart';
import 'package:recora/features/medications/domain/entities/new_medication.dart';
import 'package:recora/features/medications/presentation/widgets/medication_card.dart';
import 'package:recora/l10n/app_localizations.dart';
import 'package:recora/shared/domain/med_schedule.dart';

Widget _host(AppDatabase db, Widget child) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
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

  testWidgets('the ⋮ button on a medicine card opens the actions sheet',
      (tester) async {
    // Drift resolves its futures on real-time timers, so the seed data
    // must be written outside the widget test's fake clock.
    final med = (await tester.runAsync(() async {
      await MedicationsRepositoryImpl(db).addManual(
        NewMedication(
          name: 'Sevelamer 400 mg',
          frequencyCode: '1-0-1',
          purpose: 'Phosphate binder',
          doctor: '',
          foodRelation: MedFoodRelation.withFood,
          timesOfDay: const {},
          frequency: MedFrequency.daily,
          scheduleNote: '',
          startDate: DateTime(2026, 8, 1),
        ),
      );
      return (await db.medicationDao.watchActive().first).single;
    }))!;

    await tester.pumpWidget(_host(db, MedicationCard(medication: med)));
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit medicine'), findsOneWidget);
    expect(find.text('Mark as ended'), findsOneWidget);
    expect(find.text('Delete medicine'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('the ⋮ button on a dialysis session card opens the actions sheet',
      (tester) async {
    await tester.runAsync(
      () => DialysisRepositoryImpl(db).logSession(
        SessionLog(completedAt: DateTime(2026, 8, 19, 9), durationHours: 4),
      ),
    );

    await tester.pumpWidget(_host(db, const DialysisPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();

    expect(find.text('Edit session'), findsOneWidget);
    expect(find.text('Delete session'), findsOneWidget);

    await _unmount(tester);
  });
}
