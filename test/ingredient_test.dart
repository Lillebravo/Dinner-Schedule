import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/models/ingredient.dart';

void main() {
  group('Ingredient', () {
    test('scaled multiplies the quantity, leaving unit and name untouched', () {
      final ingredient = Ingredient(quantity: 2, unit: 'cups', name: 'flour');
      final scaled = ingredient.scaled(1.5);

      expect(scaled.quantity, 3);
      expect(scaled.unit, 'cups');
      expect(scaled.name, 'flour');
    });

    test('scaling an ingredient with no quantity is a no-op', () {
      final ingredient = Ingredient(name: 'salt to taste');
      expect(ingredient.scaled(2).quantity, isNull);
      expect(ingredient.scaled(2), ingredient);
    });

    test('trims the name', () {
      expect(Ingredient(name: '  Onion  ').name, 'Onion');
    });

    test('equality is based on quantity, unit, and name', () {
      expect(Ingredient(quantity: 2, unit: 'cups', name: 'flour'), Ingredient(quantity: 2, unit: 'cups', name: 'flour'));
      expect(Ingredient(quantity: 2, unit: 'cups', name: 'flour') == Ingredient(quantity: 3, unit: 'cups', name: 'flour'), isFalse);
    });
  });
}
