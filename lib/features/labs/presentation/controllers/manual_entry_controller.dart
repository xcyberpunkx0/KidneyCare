import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../shared/domain/lab_metric.dart';
import '../../data/repository_impl/labs_repository_impl.dart';

@immutable
class ManualEntryState {
  const ManualEntryState({this.saving = false, this.failure});

  final bool saving;
  final AppFailure? failure;
}

/// Saves a manually typed set of lab values.
class ManualEntryController extends Notifier<ManualEntryState> {
  @override
  ManualEntryState build() => const ManualEntryState();

  /// Parses raw field text into values; blank fields are skipped. Returns
  /// null when a non-blank field is not a valid number. Metrics listed in
  /// [inAltUnit] were typed in their report unit and are converted to the
  /// canonical unit here.
  static Map<LabMetric, double>? parseValues(
    Map<LabMetric, String> raw, {
    Set<LabMetric> inAltUnit = const {},
  }) {
    final values = <LabMetric, double>{};
    for (final MapEntry(key: metric, value: text) in raw.entries) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) continue;
      final value = double.tryParse(trimmed);
      if (value == null) return null;
      final factor = metric.altUnitFactor;
      values[metric] = inAltUnit.contains(metric) && factor != null
          ? value * factor
          : value;
    }
    return values;
  }

  Future<bool> save({
    required DateTime takenAt,
    required Map<LabMetric, double> values,
  }) async {
    if (values.isEmpty) {
      state = const ManualEntryState(
        failure: ValidationFailure(
            message: 'Enter at least one value before saving.'),
      );
      return false;
    }
    state = const ManualEntryState(saving: true);
    final result = await ref
        .read(labsRepositoryProvider)
        .saveManualEntry(takenAt: takenAt, values: values);
    return result.when(
      ok: (_) {
        state = const ManualEntryState();
        return true;
      },
      err: (failure) {
        state = ManualEntryState(failure: failure);
        return false;
      },
    );
  }

  void dismissFailure() => state = const ManualEntryState();
}

final manualEntryProvider =
    NotifierProvider<ManualEntryController, ManualEntryState>(
  ManualEntryController.new,
);
