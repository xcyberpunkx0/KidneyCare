import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../shared/domain/document_type.dart';
import '../../../patient/data/repository_impl/patient_repository_impl.dart';
import '../../domain/usecases/build_vitals_snapshot.dart';

/// Full lab history (oldest first) shared by vitals and attention logic.
final _allLabsProvider = StreamProvider<List<LabResult>>((ref) {
  return ref.watch(databaseProvider).labDao.watchAll();
});

final _activeMedCountProvider = StreamProvider<int>((ref) {
  return ref.watch(databaseProvider).medicationDao.watchActiveCount();
});

/// Vitals tiles + needs-attention rows, recomputed whenever any input
/// stream emits.
final vitalsSnapshotProvider = Provider<AsyncValue<VitalsSnapshot>>((ref) {
  final patient = ref.watch(patientProvider);
  final labs = ref.watch(_allLabsProvider);
  final medCount = ref.watch(_activeMedCountProvider);

  if (labs.isLoading || patient.isLoading || medCount.isLoading) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(buildVitalsSnapshot(
    patient: patient.value,
    allLabs: labs.value ?? const [],
    activeMedCount: medCount.value ?? 0,
  ));
});

final nextDialysisProvider = StreamProvider<DialysisSession?>((ref) {
  return ref
      .watch(databaseProvider)
      .dialysisDao
      .watchNextSession(DateTime.now());
});

final lastDialysisProvider = StreamProvider<DialysisSession?>((ref) {
  return ref.watch(databaseProvider).dialysisDao.watchLastCompleted();
});

final todaysDosesProvider = StreamProvider<List<Dose>>((ref) {
  return ref.watch(databaseProvider).doseDao.watchForDay(DateTime.now());
});

final recentEventsProvider = StreamProvider<List<TimelineEvent>>((ref) {
  return ref.watch(databaseProvider).timelineDao.watchRecent(3);
});

final documentCountsProvider = StreamProvider<Map<DocumentType, int>>((ref) {
  return ref.watch(databaseProvider).documentDao.watchCountsByType();
});

/// Marks a dose taken/skipped from the today strip.
final doseToggleProvider = Provider<Future<void> Function(Dose)>((ref) {
  final dao = ref.watch(databaseProvider).doseDao;
  return (dose) => dao.setTaken(dose.id, taken: !dose.taken);
});
