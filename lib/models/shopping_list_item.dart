/// One consolidated ingredient entry on a week's shopping list: how many times
/// it's needed across the week's home-cooked dinners, and which meals need it.
class ShoppingListItem {
  const ShoppingListItem({required this.name, required this.count, required this.mealNames});

  /// The ingredient text as originally entered on a meal's recipe.
  final String name;

  /// How many scheduled dinners this week call for this ingredient.
  final int count;

  /// Names of the meals (in schedule order) that need this ingredient, may
  /// repeat if the same meal is scheduled more than once in the week.
  final List<String> mealNames;

  /// A case/whitespace-insensitive key so "Onion" and "onion " merge together.
  String get key => name.trim().toLowerCase();
}
