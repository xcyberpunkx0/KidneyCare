import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/timeline_event_type.dart';

@immutable
class SymptomLogState {
  const SymptomLogState({this.saving = false, this.failure});

  final bool saving;
  final AppFailure? failure;
}

/// Records observed symptoms as a timeline entry, so nothing is forgotten
/// by the next appointment.
class SymptomLogController extends Notifier<SymptomLogState> {
  static const _uuid = Uuid();

  @override
  SymptomLogState build() => const SymptomLogState();

  Future<bool> save({
    required Set<String> symptoms,
    required String note,
  }) async {
    if (symptoms.isEmpty && note.trim().isEmpty) {
      state = const SymptomLogState(
        failure: ValidationFailure(
            message: 'Pick a symptom or write a note first.'),
      );
      return false;
    }
    state = const SymptomLogState(saving: true);
    final result = await Result.guard(() async {
      final db = ref.read(databaseProvider);
      await db.timelineDao.insert(TimelineEventsCompanion(
        id: Value(_uuid.v4()),
        type: const Value(TimelineEventType.symptom),
        title: Value(symptoms.isEmpty
            ? 'Symptom noted'
            : symptoms.join(', ')),
        subtitle: Value(note.trim()),
        occurredAt: Value(DateTime.now()),
      ));
    });
    return result.when(
      ok: (_) {
        state = const SymptomLogState();
        return true;
      },
      err: (failure) {
        state = SymptomLogState(failure: failure);
        return false;
      },
    );
  }

  void dismissFailure() => state = const SymptomLogState();
}

final symptomLogProvider =
    NotifierProvider<SymptomLogController, SymptomLogState>(
  SymptomLogController.new,
);
