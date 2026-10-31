import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/utils/recipe_steps.dart';

void main() {
  group('RecipeSteps', () {
    test('splits one step per non-blank line', () {
      expect(
        RecipeSteps.from('Chop onions.\nSear the meat.\nSimmer for 20 minutes.'),
        ['Chop onions.', 'Sear the meat.', 'Simmer for 20 minutes.'],
      );
    });

    test('trims each step and drops blank lines', () {
      expect(
        RecipeSteps.from('  Preheat the oven.  \n\n\nServe hot.\n   \n'),
        ['Preheat the oven.', 'Serve hot.'],
      );
    });

    test('returns an empty list for blank or empty instructions', () {
      expect(RecipeSteps.from(''), isEmpty);
      expect(RecipeSteps.from('   \n  \n'), isEmpty);
    });
  });
}
