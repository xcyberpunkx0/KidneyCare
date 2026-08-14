import '../../../../shared/domain/med_schedule.dart';

/// A medicine typed in by the caregiver, before persistence.
class NewMedication {
  const NewMedication({
    required this.name,
    required this.frequencyCode,
    required this.purpose,
    required this.doctor,
    required this.scheduleGroup,
    required this.timingCues,
    required this.scheduleNote,
    required this.startDate,
  });

  /// Drug with strength, e.g. "Sevelamer 400 mg".
  final String name;

  /// Dose pattern, e.g. "1-0-1" or "weekly".
  final String frequencyCode;

  final String purpose;
  final String doctor;
  final MedScheduleGroup scheduleGroup;
  final Set<MedTimingCue> timingCues;
  final String scheduleNote;
  final DateTime startDate;
}
