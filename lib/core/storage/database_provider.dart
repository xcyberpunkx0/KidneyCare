import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Single app-wide database instance. Overridden in tests with an in-memory
/// executor via [AppDatabase.forTesting].
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
