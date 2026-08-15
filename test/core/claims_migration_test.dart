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

  test('v5 vault upgrades cleanly to v6', () async {
    final connection = await verifier.startAt(5);
    final db = AppDatabase.forTesting(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);
  });
}
