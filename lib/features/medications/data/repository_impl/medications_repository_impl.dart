import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/timeline_event_type.dart';
import '../../domain/entities/new_medication.dart';
import '../../domain/repositories/medications_repository.dart';

class MedicationsRepositoryImpl implements MedicationsRepository {
  MedicationsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _uuid = Uuid();

  @override
  Stream<List<Medication>> watchActive() => _db.medicationDao.watchActive();

  @override
  Stream<List<Medication>> watchEnded() => _db.medicationDao.watchEnded();

  @override
  Future<Result<void>> addManual(NewMedication medication) {
    return Result.guard(() async {
      await _db.transaction(() async {
        await _db.medicationDao.upsert(
          MedicationsCompanion(
            id: Value(_uuid.v4()),
            name: Value(medication.name),
            // Strength is typed as part of the name ("Sevelamer 400 mg");
            // the standalone dose column stays empty for manual entries.
            dose: const Value(''),
            frequencyCode: Value(medication.frequencyCode),
            purpose: Value(medication.purpose),
            doctor: Value(medication.doctor),
            foodRelation: Value(medication.foodRelation),
            timeOfDayJson: Value(
              jsonEncode([for (final t in medication.timesOfDay) t.name]),
            ),
            frequency: Value(medication.frequency),
            scheduleNote: Value(medication.scheduleNote),
            startDate: Value(medication.startDate),
            intervalDays: Value(medication.intervalDays),
          ),
        );
        await _db.timelineDao.insert(
          TimelineEventsCompanion(
            id: Value(_uuid.v4()),
            type: const Value(TimelineEventType.medicationChange),
            title: Value('Started ${medication.name}'),
            subtitle: Value(
              [
                'Manual entry',
                if (medication.doctor.isNotEmpty) medication.doctor,
              ].join(' · '),
            ),
            occurredAt: Value(medication.startDate),
          ),
        );
      });
    });
  }

  @override
  Future<Medication?> getMedication(String id) => _db.medicationDao.getById(id);

  @override
  Future<Result<void>> updateManual(String id, NewMedication medication) {
    return Result.guard(() async {
      final existing = await _db.medicationDao.getById(id);
      if (existing == null) return;
      await _db.medicationDao.upsert(
        existing
            .toCompanion(false)
            .copyWith(
              name: Value(medication.name),
              frequencyCode: Value(medication.frequencyCode),
              purpose: Value(medication.purpose),
              doctor: Value(medication.doctor),
              foodRelation: Value(medication.foodRelation),
              timeOfDayJson: Value(
                jsonEncode([for (final t in medication.timesOfDay) t.name]),
              ),
              frequency: Value(medication.frequency),
              scheduleNote: Value(medication.scheduleNote),
              intervalDays: Value(medication.intervalDays),
            ),
      );
    });
  }

  @override
  Future<Result<void>> deleteMedication(String id) {
    return Result.guard(() async {
      final med = await _db.medicationDao.getById(id);
      if (med == null) return;
      await _db.transaction(() async {
        await _db.doseDao.deleteForMedication(id);
        await _db.timelineDao.deleteByTypeAndTitles(
          TimelineEventType.medicationChange,
          ['Started ${med.name}', 'Stopped ${med.name}', 'Given ${med.name}'],
        );
        await _db.medicationDao.deleteById(id);
      });
    });
  }

  @override
  Future<Result<void>> markGiven(String id, DateTime on) {
    return Result.guard(() async {
      final med = await _db.medicationDao.getById(id);
      if (med == null) return;
      final day = DateTime(on.year, on.month, on.day);
      await _db.transaction(() async {
        await _db.medicationDao.upsert(
          med.toCompanion(false).copyWith(lastGivenOn: Value(day)),
        );
        await _db.timelineDao.insert(
          TimelineEventsCompanion(
            id: Value(_uuid.v4()),
            type: const Value(TimelineEventType.medicationChange),
            title: Value('Given ${med.name}'),
            subtitle: Value('Every ${med.intervalDays} days'),
            occurredAt: Value(day),
          ),
        );
      });
    });
  }

  @override
  Future<Result<void>> undoGiven(String id, DateTime on) {
    return Result.guard(() async {
      final med = await _db.medicationDao.getById(id);
      final day = DateTime(on.year, on.month, on.day);
      if (med == null || med.lastGivenOn != day) return;
      await _db.transaction(() async {
        await _db.timelineDao.deleteByTypeTitleAt(
          TimelineEventType.medicationChange,
          'Given ${med.name}',
          day,
        );
        final previous = await _db.timelineDao.getLatestByTypeAndTitle(
          TimelineEventType.medicationChange,
          'Given ${med.name}',
        );
        await _db.medicationDao.upsert(
          med
              .toCompanion(false)
              .copyWith(lastGivenOn: Value(previous?.occurredAt)),
        );
      });
    });
  }

  @override
  Future<Result<void>> endMedication(String id) {
    return Result.guard(() async {
      final active = await _db.medicationDao.watchActive().first;
      final med = active.where((m) => m.id == id).firstOrNull;
      if (med == null) return;
      await _db.transaction(() async {
        await _db.medicationDao.upsert(
          med.toCompanion(false).copyWith(endDate: Value(DateTime.now())),
        );
        await _db.timelineDao.insert(
          TimelineEventsCompanion(
            id: Value(_uuid.v4()),
            type: const Value(TimelineEventType.medicationChange),
            title: Value('Stopped ${med.name}'),
            subtitle: const Value('Marked ended by caregiver'),
            occurredAt: Value(DateTime.now()),
          ),
        );
      });
    });
  }
}

final medicationsRepositoryProvider = Provider<MedicationsRepository>((ref) {
  return MedicationsRepositoryImpl(ref.watch(databaseProvider));
});

final activeMedicationsProvider = StreamProvider<List<Medication>>((ref) {
  return ref.watch(medicationsRepositoryProvider).watchActive();
});

final endedMedicationsProvider = StreamProvider<List<Medication>>((ref) {
  return ref.watch(medicationsRepositoryProvider).watchEnded();
});
