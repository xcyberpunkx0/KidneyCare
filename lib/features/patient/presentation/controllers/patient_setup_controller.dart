import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../data/repository_impl/patient_repository_impl.dart';
import '../../domain/entities/patient_profile.dart';

@immutable
class PatientSetupState {
  const PatientSetupState({this.saving = false, this.failure});

  final bool saving;
  final AppFailure? failure;
}

/// Saves the patient profile from onboarding or the edit form; can seed
/// the vault with sample data instead for exploration.
class PatientSetupController extends Notifier<PatientSetupState> {
  @override
  PatientSetupState build() => const PatientSetupState();

  Future<bool> save(PatientProfile profile) async {
    state = const PatientSetupState(saving: true);
    final result =
        await ref.read(patientRepositoryProvider).saveProfile(profile);
    return result.when(
      ok: (_) {
        state = const PatientSetupState();
        return true;
      },
      err: (failure) {
        state = PatientSetupState(failure: failure);
        return false;
      },
    );
  }

  Future<bool> exploreWithSampleData() async {
    state = const PatientSetupState(saving: true);
    final result = await Result.guard(
      () => ref.read(databaseProvider).seedDemo(),
    );
    return result.when(
      ok: (_) {
        state = const PatientSetupState();
        return true;
      },
      err: (failure) {
        state = PatientSetupState(failure: failure);
        return false;
      },
    );
  }

  void dismissFailure() => state = const PatientSetupState();
}

final patientSetupProvider =
    NotifierProvider<PatientSetupController, PatientSetupState>(
  PatientSetupController.new,
);
