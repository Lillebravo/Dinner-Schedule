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
    List<String>? ingredients,
    this.instructions = '',
    this.cookTimeMinutes,
    this.isFavorite = false,
    Set<MealTag>? tags,
  })  : name = name.trim(),
        ingredients = ingredients ?? [],
        tags = tags ?? {};

  final String name;
  List<String> ingredients;
  String instructions;
  int? cookTimeMinutes;
  bool isFavorite;
  Set<MealTag> tags;

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
