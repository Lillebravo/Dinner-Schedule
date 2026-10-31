import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/utils/quantity_format.dart';

void main() {
  group('QuantityFormat', () {
    test('formats whole numbers without a decimal point', () {
      expect(QuantityFormat.format(2), '2');
      expect(QuantityFormat.format(0), '0');
    });

    test('formats quarter fractions with glyphs', () {
      expect(QuantityFormat.format(0.25), '\u00bc');
      expect(QuantityFormat.format(0.5), '\u00bd');
      expect(QuantityFormat.format(0.75), '\u00be');
      expect(QuantityFormat.format(1.5), '1\u00bd');
      expect(QuantityFormat.format(2.25), '2\u00bc');
    });

    test('rounds floating-point noise from scaling to the nearest quarter', () {
      // Scaling routinely produces values like this instead of a clean 1.5.
      expect(QuantityFormat.format(1.4999999999999998), '1\u00bd');
      expect(QuantityFormat.format(2.5000000000000004), '2\u00bd');
    });

    test('formats metric weight/volume units as decimals instead of fractions', () {
      expect(QuantityFormat.format(50.5, unit: 'g'), '50.5');
      expect(QuantityFormat.format(50.5, unit: 'G'), '50.5');
      expect(QuantityFormat.format(2, unit: 'kg'), '2');
      expect(QuantityFormat.format(1.5, unit: 'ml'), '1.5');
      expect(QuantityFormat.format(1.5, unit: 'cups'), '1\u00bd');
    });

    test('withUnit joins metric abbreviations tight against the number', () {
      expect(QuantityFormat.withUnit(50.5, 'g'), '50.5g');
      expect(QuantityFormat.withUnit(2, 'kg'), '2kg');
      expect(QuantityFormat.withUnit(5, ''), '5');
    });

    test('withUnit puts a space before non-metric units', () {
      expect(QuantityFormat.withUnit(1.5, 'cups'), '1\u00bd cups');
      expect(QuantityFormat.withUnit(2, 'tbsp'), '2 tbsp');
    });

    test('parse accepts a plain decimal', () {
      expect(QuantityFormat.parse('0.5'), 0.5);
      expect(QuantityFormat.parse('2'), 2.0);
    });

    test('parse accepts a simple fraction', () {
      expect(QuantityFormat.parse('1/2'), 0.5);
      expect(QuantityFormat.parse('3/4'), 0.75);
    });

    test('parse accepts a mixed number', () {
      expect(QuantityFormat.parse('1 1/2'), 1.5);
    });

    test('parse returns null for blank input or a zero denominator', () {
      expect(QuantityFormat.parse(''), isNull);
      expect(QuantityFormat.parse('   '), isNull);
      expect(QuantityFormat.parse('1/0'), isNull);
    });
  });
}
