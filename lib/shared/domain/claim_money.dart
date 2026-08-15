import 'package:intl/intl.dart';

/// Formats integer paise as Indian rupees: `formatPaise(1240000)` →
/// "₹12,400". Whole-rupee amounts drop the decimals.
String formatPaise(int paise) {
  final format = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: paise % 100 == 0 ? 0 : 2,
  );
  return format.format(paise / 100);
}

/// Parses caregiver-typed rupees ("12,400", "₹ 99.50") into paise.
/// Null when the input is not a non-negative amount with at most two
/// decimal places.
int? parsePaise(String input) {
  final cleaned = input.replaceAll('₹', '').replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;
  final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(cleaned);
  if (match == null) return null;
  final rupees = int.parse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(2, '0');
  return rupees * 100 + int.parse(fraction);
}
