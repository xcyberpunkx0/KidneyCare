import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../data/repository_impl/medications_repository_impl.dart';
import '../../domain/entities/new_medication.dart';

@immutable
class AddMedicationState {
  const AddMedicationState({this.saving = false, this.failure});

  final bool saving;
  final AppFailure? failure;
}

class AddMedicationController extends Notifier<AddMedicationState> {
  @override
  AddMedicationState build() => const AddMedicationState();

  Future<bool> save(NewMedication medication) async {
    if (!_validate(medication)) return false;
    state = const AddMedicationState(saving: true);
    final result = await ref
        .read(medicationsRepositoryProvider)
        .addManual(medication);
    return _finish(result);
  }

  /// Rewrites an existing medication's details.
  Future<bool> update(String id, NewMedication medication) async {
    if (!_validate(medication)) return false;
    state = const AddMedicationState(saving: true);
    final result = await ref
        .read(medicationsRepositoryProvider)
        .updateManual(id, medication);
    return _finish(result);
  }

  bool _validate(NewMedication medication) {
    if (medication.name.trim().isEmpty) {
      state = const AddMedicationState(
        failure: ValidationFailure(message: 'Please enter the medicine name.'),
      );
      return false;
    }
    return true;
  }

  bool _finish(Result<void> result) {
    return result.when(
      ok: (_) {
        state = const AddMedicationState();
        return true;
      },
      err: (failure) {
        state = AddMedicationState(failure: failure);
        return false;
      },
    );
  }

  void dismissFailure() => state = const AddMedicationState();
}

final addMedicationProvider =
    NotifierProvider<AddMedicationController, AddMedicationState>(
      AddMedicationController.new,
    );
