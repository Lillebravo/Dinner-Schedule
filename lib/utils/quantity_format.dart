/// Formats a scaled ingredient quantity for display, and parses quantity text
/// a user typed into the ingredient editor - kept free of Flutter widgets so
/// both can be unit tested directly (mirrors [CalendarMath]).
class QuantityFormat {
  const QuantityFormat._();

  static final _fractionGlyphs = {0.25: '\u00bc', 0.5: '\u00bd', 0.75: '\u00be'};

  /// Units whose amounts read naturally as decimals (e.g. "50.5g") - showing a
  /// fraction instead (e.g. "50 \u00bdg") looks wrong for metric weights/volumes.
  static const _decimalUnits = {
    'g', 'gram', 'grams',
    'hg',
    'kg', 'kilo', 'kilos', 'kilogram', 'kilograms',
    'mg', 'milligram', 'milligrams',
    'ml', 'milliliter', 'milliliters', 'millilitre', 'millilitres',
    'l', 'liter', 'liters', 'litre', 'litres', 'dl', 'cl',
  };

  /// Formats [quantity] for display. For [unit]s that read naturally as
  /// decimals (metric weights/volumes like "g" or "kg"), this rounds to one
  /// decimal place (e.g. "50.5"). Otherwise it rounds to the nearest quarter
  /// and renders as a fraction (e.g. "1\u00bd") - scaling a recipe (e.g. by
  /// 1.5x) routinely produces values like `1.4999999999999998`, so rounding
  /// first keeps the result clean instead of showing floating-point noise.
  static String format(double quantity, {String unit = ''}) {
    return _decimalUnits.contains(unit.trim().toLowerCase()) ? _formatDecimal(quantity) : _formatFraction(quantity);
  }

  /// Combines a formatted [quantity] with [unit] the way it reads naturally:
  /// tight against the number for compact metric abbreviations (e.g.
  /// "50.5g", "2kg"), with a space for everything else (e.g. "1\u00bd cups").
  static String withUnit(double quantity, String unit) {
    final formattedQuantity = format(quantity, unit: unit);
    final trimmedUnit = unit.trim();
    if (trimmedUnit.isEmpty) return formattedQuantity;
    return _decimalUnits.contains(trimmedUnit.toLowerCase()) ? '$formattedQuantity$trimmedUnit' : '$formattedQuantity $trimmedUnit';
  }

  static String _formatDecimal(double quantity) {
    final rounded = (quantity * 10).round() / 10;
    final whole = rounded.truncate();
    return rounded == whole ? whole.toString() : rounded.toStringAsFixed(1);
  }

  static String _formatFraction(double quantity) {
    final rounded = (quantity * 4).round() / 4;
    final whole = rounded.truncate();
    final fraction = rounded - whole;

    final glyph = _fractionGlyphs[fraction];
    if (glyph == null) return whole.toString();
    return whole == 0 ? glyph : '$whole$glyph';
  }

  static final _mixedNumber = RegExp(r'^(\d+)\s+(\d+)\s*/\s*(\d+)$');
  static final _simpleFraction = RegExp(r'^(\d+)\s*/\s*(\d+)$');

  /// Parses quantity text a user typed into the ingredient editor. Accepts a
  /// plain decimal ("0.5"), a simple fraction ("1/2"), or a mixed number
  /// ("1 1/2"); returns null for anything it can't make sense of (including a
  /// blank field, or a fraction with a zero denominator).
  static double? parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final mixed = _mixedNumber.firstMatch(trimmed);
    if (mixed != null) {
      final denominator = int.parse(mixed.group(3)!);
      if (denominator == 0) return null;
      return int.parse(mixed.group(1)!) + int.parse(mixed.group(2)!) / denominator;
    }

    final fraction = _simpleFraction.firstMatch(trimmed);
    if (fraction != null) {
      final denominator = int.parse(fraction.group(2)!);
      if (denominator == 0) return null;
      return int.parse(fraction.group(1)!) / denominator;
    }

    return double.tryParse(trimmed);
  }
}
