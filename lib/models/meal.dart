import 'ingredient.dart';

/// A characteristic a meal can be tagged with, used to filter the meals list and wheel.
enum MealTag {
  vegetarian('Vegetarian'),
  vegan('Vegan'),
  pescatarian('Pescatarian'),
  glutenFree('Gluten-Free'),
  comfortFood('Comfort Food'),
  pantryFriendly('Pantry Friendly');

  const MealTag(this.label);
  final String label;
}

/// A home-cooked meal, with enough detail to actually cook it.
class Meal {
  Meal({
    required String name,
    List<Ingredient>? ingredients,
    this.instructions = '',
    this.cookTimeMinutes,
    this.isFavorite = false,
    Set<MealTag>? tags,
    Set<String>? customTags,
    int servings = defaultServings,
  })  : name = name.trim(),
        ingredients = ingredients ?? [],
        tags = tags ?? {},
        customTags = customTags ?? {},
        servings = servings < 1 ? 1 : servings;

  /// The serving count new meals start at, and the denominator [ingredients]'
  /// quantities are written against until the user changes it.
  static const int defaultServings = 4;

  final String name;
  List<Ingredient> ingredients;
  String instructions;
  int? cookTimeMinutes;
  bool isFavorite;
  Set<MealTag> tags;

  /// Free-text tags the user made up themselves (e.g. "Kid-Friendly"), on top
  /// of the built-in [MealTag]s - also usable to filter the meals list and
  /// wheel. The vocabulary of tags ever created is tracked separately by
  /// [MealListController.knownCustomTags] so it survives even after being
  /// removed from every meal.
  Set<String> customTags;

  /// How many servings [ingredients]' quantities are written for - the
  /// denominator used to scale them up/down in cooking mode.
  int servings;

  /// Whether this meal is quick to cook, per the app's "Quick (<30m)" filter.
  bool get isQuick => cookTimeMinutes != null && cookTimeMinutes! < 30;

  /// Whether this meal's name matches [other], ignoring case and surrounding whitespace.
  bool matchesName(String other) => name.toLowerCase() == other.trim().toLowerCase();

  @override
  bool operator ==(Object other) => other is Meal && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
