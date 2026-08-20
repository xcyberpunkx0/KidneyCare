import '../../../../core/storage/app_database.dart';

/// Due-date arithmetic for interval medicines ("every N days"), kept as
/// pure date math so the checklist, home card and tests all agree.
extension IntervalDueX on Medication {
  bool get isIntervalMed => intervalDays != null;

  /// The day this medicine should next be given: [intervalDays] after the
  /// last given day, or today when it has never been marked given. Null
  /// for medicines without an interval.
  DateTime? nextDueOn(DateTime today) {
    final interval = intervalDays;
    if (interval == null) return null;
    final last = lastGivenOn;
    if (last == null) return _day(today);
    return _day(last).add(Duration(days: interval));
  }

  /// Whether the medicine is due (or overdue) on [today].
  bool isDueOn(DateTime today) {
    final due = nextDueOn(today);
    return due != null && !due.isAfter(_day(today));
  }

  /// How many days past due the medicine is on [today]; 0 when due today
  /// or not due at all.
  int overdueDaysOn(DateTime today) {
    final due = nextDueOn(today);
    if (due == null) return 0;
    final days = _day(today).difference(due).inDays;
    return days > 0 ? days : 0;
  }

  /// Whether it was already marked given on [today].
  bool wasGivenOn(DateTime today) {
    final last = lastGivenOn;
    return last != null && _day(last) == _day(today);
  }
}

DateTime _day(DateTime at) => DateTime(at.year, at.month, at.day);
