import 'package:intl/intl.dart';

/// Shared date formatting used across features.
extension DateFormatX on DateTime {
  /// "Aug 2"
  String get monthDay => DateFormat('MMM d').format(this);

  /// "Aug 2, 2026"
  String get monthDayYear => DateFormat('MMM d, y').format(this);

  /// "AUGUST 2026" — timeline month group header.
  String get monthGroupLabel =>
      DateFormat('MMMM y').format(this).toUpperCase();

  /// "Wed, 7:00 AM"
  String get weekdayTime => DateFormat('EEE, h:mm a').format(this);

  /// Whole hours from now, e.g. "in 14 h".
  String inHoursLabel(DateTime from) {
    final hours = difference(from).inHours;
    if (hours <= 0) return 'now';
    return 'in $hours h';
  }
}
