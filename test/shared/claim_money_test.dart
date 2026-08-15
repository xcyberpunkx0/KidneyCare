import 'package:flutter_test/flutter_test.dart';
import 'package:recora/shared/domain/claim_money.dart';

void main() {
  group('formatPaise', () {
    test('whole rupees drop the decimals and use Indian grouping', () {
      expect(formatPaise(1240000), '₹12,400');
      expect(formatPaise(123456700), '₹12,34,567');
      expect(formatPaise(0), '₹0');
    });

    test('fractional rupees keep two decimals', () {
      expect(formatPaise(9950), '₹99.50');
    });
  });

  group('parsePaise', () {
    test('accepts plain, comma-grouped and ₹-prefixed rupees', () {
      expect(parsePaise('12400'), 1240000);
      expect(parsePaise('12,400'), 1240000);
      expect(parsePaise('₹ 12,400'), 1240000);
      expect(parsePaise('99.50'), 9950);
    });

    test('rejects junk, negatives and blank input', () {
      expect(parsePaise('twelve'), isNull);
      expect(parsePaise('-5'), isNull);
      expect(parsePaise(''), isNull);
      expect(parsePaise('12.345'), isNull);
    });
  });
}
