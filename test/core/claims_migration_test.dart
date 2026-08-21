import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/shared/domain/med_schedule.dart';

import '../generated_migrations/schema.dart';

void main() {
  // If this fails on Windows with "Failed to load dynamic library
  // sqlite3.dll", see the sqlite3.dll note in the plan's Global
  // Constraints.
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // Each historical version must reach the current schema in one upgrade,
  // exactly as a real vault does. (The onUpgrade if-chain always applies
  // every step up to schemaVersion, so intermediate targets can't be
  // validated in isolation.)
  for (final from in const [5, 6, 7, 8]) {
    test('v$from vault upgrades cleanly to the current schema', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase.forTesting(connection);
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 9);
    });
  }

  test('v8 medicine schedules convert to the three new axes', () async {
    final schema = await verifier.schemaAt(8);
    addTearDown(schema.close);

    // Drift stores DateTimes as unix seconds.
    final startSecs =
        DateTime(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;
    final lastGivenSecs =
        DateTime(2026, 8, 14).millisecondsSinceEpoch ~/ 1000;

    void insert(
      String id,
      String group,
      String cues, {
      int? intervalDays,
      int? lastGivenOn,
    }) {
      schema.rawDatabase.execute(
        'INSERT INTO medications (id, name, dose, frequency_code, purpose, '
        'schedule_group, timing_cues_json, start_date, interval_days, '
        'last_given_on) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [id, id, '', '1-0-1', '', group, cues, startSecs, intervalDays,
            lastGivenOn],
      );
    }

    insert('with-food', 'withFood', '["withFood"]');
    insert('before-food', 'byClock', '["beforeFood","morning"]');
    insert('after-food', 'byClock', '["afterFood","night"]');
    insert('clock-only', 'byClock', '["morning","noon"]');
    insert('dialysis', 'weekly', '["dialysisDayOnly"]');
    insert('interval', 'weekly', '[]',
        intervalDays: 7, lastGivenOn: lastGivenSecs);
    insert('weekly', 'weekly', '[]');

    final db = AppDatabase.forTesting(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 9);

    final meds = {
      for (final med in await db.select(db.medications).get()) med.id: med,
    };
    expect(meds, hasLength(7));

    expect(meds['with-food']!.foodRelation, MedFoodRelation.withFood);
    expect(meds['with-food']!.timeOfDayJson, '[]');
    expect(meds['with-food']!.frequency, MedFrequency.daily);

    expect(meds['before-food']!.foodRelation, MedFoodRelation.beforeFood);
    expect(meds['before-food']!.timeOfDayJson, '["morning"]');

    expect(meds['after-food']!.foodRelation, MedFoodRelation.afterFood);
    expect(meds['after-food']!.timeOfDayJson, '["night"]');

    expect(meds['clock-only']!.foodRelation, MedFoodRelation.noRelation);
    expect(meds['clock-only']!.timeOfDayJson, '["morning","noon"]');
    expect(meds['clock-only']!.frequency, MedFrequency.daily);

    expect(meds['dialysis']!.frequency, MedFrequency.dialysisDaysOnly);

    // The table rebuild must carry the same-named columns across.
    expect(meds['interval']!.frequency, MedFrequency.everyNDays);
    expect(meds['interval']!.intervalDays, 7);
    expect(meds['interval']!.lastGivenOn, DateTime(2026, 8, 14));

    expect(meds['weekly']!.frequency, MedFrequency.weekly);
    expect(meds['weekly']!.intervalDays, isNull);

    // The legacy columns are gone after the rebuild.
    final columns = await db.customSelect(
      "SELECT name FROM pragma_table_info('medications')",
    ).get();
    final names = [for (final row in columns) row.read<String>('name')];
    expect(names, isNot(contains('schedule_group')));
    expect(names, isNot(contains('timing_cues_json')));
    expect(names, containsAll(['food_relation', 'time_of_day_json',
        'frequency', 'interval_days', 'last_given_on']));
  });
}
