/// A grocery-store section used to group the shopping list, matching how most
/// stores are laid out so the categorized checklist can be shopped section by
/// section instead of as one long undifferentiated list.
enum GroceryAisle {
  produce('Produce'),
  dairy('Dairy'),
  meat('Meat'),
  spices('Spices'),
  pantry('Pantry'),
  other('Other');

  const GroceryAisle(this.label);
  final String label;
}

/// Guesses which [GroceryAisle] a shopping list item's ingredient text belongs
/// to, from a curated list of common keywords - kept free of Flutter widgets
/// so it can be unit tested directly (mirrors [CalendarMath]/[ShoppingListMath]).
/// This is only ever a starting guess: [ShoppingListController] lets the user
/// correct it per ingredient, and that correction sticks.
class AisleCategorizer {
  const AisleCategorizer._();

  static const Map<GroceryAisle, List<String>> _keywords = {
    GroceryAisle.produce: [
      'onion', 'garlic', 'tomato', 'potato', 'carrot', 'lettuce', 'spinach', 'cucumber',
      'avocado', 'lime', 'lemon', 'apple', 'banana', 'mushroom', 'cilantro', 'parsley',
      'basil', 'ginger', 'broccoli', 'zucchini', 'corn', 'celery', 'kale', 'bell pepper',
    ],
    GroceryAisle.dairy: ['milk', 'cheese', 'butter', 'yogurt', 'cream', 'egg'],
    GroceryAisle.meat: ['chicken', 'beef', 'pork', 'fish', 'shrimp', 'bacon', 'sausage', 'turkey', 'salmon', 'steak', 'meat'],
    GroceryAisle.spices: [
      'salt', 'cumin', 'paprika', 'cinnamon', 'oregano', 'chili powder', 'spice',
      'nutmeg', 'turmeric', 'black pepper', 'bay leaf', 'thyme', 'rosemary',
    ],
    GroceryAisle.pantry: [
      'rice', 'pasta', 'flour', 'sugar', 'oil', 'beans', 'bread', 'tortilla', 'sauce',
      'broth', 'stock', 'canned', 'vinegar', 'noodle', 'cereal', 'honey', 'nuts',
    ],
  };

  /// Categorizes [ingredientName] by the first aisle whose keyword list
  /// contains a match, falling back to [GroceryAisle.other].
  static GroceryAisle categorize(String ingredientName) {
    final lower = ingredientName.toLowerCase();
    for (final entry in _keywords.entries) {
      if (entry.value.any(lower.contains)) return entry.key;
    }
    return GroceryAisle.other;
  }
}
