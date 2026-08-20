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

  // Each historical version must reach the current schema in one upgrade,
  // exactly as a real vault does. (The onUpgrade if-chain always applies
  // every step up to schemaVersion, so intermediate targets can't be
  // validated in isolation.)
  test('v5 vault upgrades cleanly to the current schema', () async {
    final connection = await verifier.startAt(5);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 8);
  });

  test('v6 vault upgrades cleanly to the current schema', () async {
    final connection = await verifier.startAt(6);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 8);
  });

  test('v7 vault upgrades cleanly to the current schema', () async {
    final connection = await verifier.startAt(7);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 8);
  });
}
