/// Splits a meal's free-form [instructions] text into individual cooking
/// steps, kept free of Flutter widgets so it can be unit tested directly
/// (mirrors [CalendarMath]/[ShoppingListMath]). Each non-blank line is treated
/// as one step; blank lines are dropped rather than treated as separators, so
/// a recipe typed with blank lines between steps doesn't produce empty steps.
class RecipeSteps {
  const RecipeSteps._();

  static List<String> from(String instructions) {
    return [
      for (final line in instructions.split('\n'))
        if (line.trim().isNotEmpty) line.trim(),
    ];
  }
}
