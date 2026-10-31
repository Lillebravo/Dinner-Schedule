import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/utils/aisle_categorizer.dart';

void main() {
  group('AisleCategorizer', () {
    test('categorizes common ingredients into the expected aisle', () {
      expect(AisleCategorizer.categorize('Onion'), GroceryAisle.produce);
      expect(AisleCategorizer.categorize('2 tomatoes'), GroceryAisle.produce);
      expect(AisleCategorizer.categorize('Milk'), GroceryAisle.dairy);
      expect(AisleCategorizer.categorize('Cheddar cheese'), GroceryAisle.dairy);
      expect(AisleCategorizer.categorize('Chicken breast'), GroceryAisle.meat);
      expect(AisleCategorizer.categorize('Ground cumin'), GroceryAisle.spices);
      expect(AisleCategorizer.categorize('Jasmine rice'), GroceryAisle.pantry);
    });

    test('is case-insensitive', () {
      expect(AisleCategorizer.categorize('ONION'), GroceryAisle.produce);
      expect(AisleCategorizer.categorize('mIlK'), GroceryAisle.dairy);
    });

    test('falls back to other for anything unrecognized', () {
      expect(AisleCategorizer.categorize('Paper towels'), GroceryAisle.other);
      expect(AisleCategorizer.categorize(''), GroceryAisle.other);
    });
  });
}
