import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';

/// The pending scheduled session, if any.
final nextSessionProvider = StreamProvider<DialysisSession?>((ref) {
  return ref
      .watch(databaseProvider)
      .dialysisDao
      .watchNextSession(DateTime.now());
});

/// The most recent completed session.
final lastSessionProvider = StreamProvider<DialysisSession?>((ref) {
  return ref.watch(databaseProvider).dialysisDao.watchLastCompleted();
});

/// All completed sessions, most recent first.
final sessionHistoryProvider =
    StreamProvider<List<DialysisSession>>((ref) {
  return ref.watch(databaseProvider).dialysisDao.watchCompleted();
});
