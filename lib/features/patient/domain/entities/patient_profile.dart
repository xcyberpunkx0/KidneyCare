import 'dart:convert';

/// Editable patient details captured at onboarding (or later from
/// settings). Kept separate from the persistence row so the form layer
/// never touches database types.
class PatientProfile {
  const PatientProfile({
    required this.name,
    required this.age,
    required this.condition,
    required this.schedule,
    required this.center,
    required this.dryWeightKg,
    this.bloodGroup = '',
    this.allergies = '',
    this.emergencyContact = '',
    this.comorbidities = '',
  });

  final String name;
  final int age;

  /// Diagnosis shorthand, e.g. "CKD-5".
  final String condition;

  /// Dialysis schedule: weekday ([DateTime.monday]..[DateTime.sunday]) →
  /// session start as minutes past midnight. Days may have different
  /// times, and any time of day is valid.
  final Map<int, int> schedule;

  final String center;
  final double dryWeightKg;

  /// Emergency-card details, e.g. "B+".
  final String bloodGroup;
  final String allergies;
  final String emergencyContact;

  /// Comma-separated other conditions, kept in English for medical staff,
  /// e.g. "Diabetes, Hypertension, Chronic pancreatitis".
  final String comorbidities;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '·';
    final letters = parts
        .map((part) => part.replaceAll(RegExp(r'[^A-Za-z]'), ''))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();
    return letters.isEmpty ? '·' : letters;
  }

  static const dayNames = {
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  /// "CKD-5, HD Mon/Wed/Fri" — the identity line under the app name.
  String get conditionSummary {
    final days = (schedule.keys.toList()..sort())
        .map((day) => dayNames[day])
        .join('/');
    return days.isEmpty ? condition : '$condition, HD $days';
  }

  /// The next session start strictly after [from], honoring each day's
  /// own start time.
  DateTime? nextSession(DateTime from) {
    if (schedule.isEmpty) return null;
    DateTime? earliest;
    for (final MapEntry(key: weekday, value: minutes) in schedule.entries) {
      var candidate = DateTime(
          from.year, from.month, from.day, minutes ~/ 60, minutes % 60);
      while (candidate.weekday != weekday || !candidate.isAfter(from)) {
        candidate = DateTime(candidate.year, candidate.month,
            candidate.day + 1, minutes ~/ 60, minutes % 60);
      }
      if (earliest == null || candidate.isBefore(earliest)) {
        earliest = candidate;
      }
    }
    return earliest;
  }

  String scheduleToJson() =>
      jsonEncode(schedule.map((day, hour) => MapEntry('$day', hour)));

  static Map<int, int> scheduleFromJson(String json) {
    final raw = jsonDecode(json);
    if (raw is! Map<String, dynamic>) return {};
    return {
      for (final MapEntry(:key, :value) in raw.entries)
        if (int.tryParse(key) != null && value is int)
          int.parse(key): value,
    };
  }
}
