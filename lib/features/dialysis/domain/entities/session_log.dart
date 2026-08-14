/// A completed dialysis session as recorded by the caregiver.
class SessionLog {
  const SessionLog({
    required this.completedAt,
    required this.durationHours,
    this.preWeightKg,
    this.postWeightKg,
    this.ultrafiltrationL,
    this.systolic,
    this.diastolic,
    this.note = '',
  });

  final DateTime completedAt;
  final double durationHours;
  final double? preWeightKg;
  final double? postWeightKg;
  final double? ultrafiltrationL;
  final double? systolic;
  final double? diastolic;

  /// Free note, e.g. "no cramps" or "BP dipped mid-session".
  final String note;

  /// "UF 2.8 L · 60.1 → 57.4 kg" — the timeline subtitle.
  String get summaryLine {
    final parts = <String>[
      if (ultrafiltrationL != null)
        'UF ${ultrafiltrationL!.toStringAsFixed(1)} L',
      if (preWeightKg != null && postWeightKg != null)
        '${preWeightKg!.toStringAsFixed(1)} → '
            '${postWeightKg!.toStringAsFixed(1)} kg',
      if (note.isNotEmpty) note,
    ];
    return parts.join(' · ');
  }
}
