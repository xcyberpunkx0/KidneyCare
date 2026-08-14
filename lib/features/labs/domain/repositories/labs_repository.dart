import '../../../../core/utils/result.dart';
import '../../../../shared/domain/lab_metric.dart';
import '../entities/lab_series.dart';

/// Access to laboratory history, grouped per metric.
abstract interface class LabsRepository {
  /// All series with at least one observation, in [LabMetric] order.
  Stream<List<LabSeries>> watchAllSeries();

  /// Stores manually entered values dated [takenAt] and records the entry
  /// on the timeline. Used when there is no report to photograph.
  Future<Result<void>> saveManualEntry({
    required DateTime takenAt,
    required Map<LabMetric, double> values,
  });
}
