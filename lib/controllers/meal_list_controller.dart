import 'package:flutter/foundation.dart';

import '../models/meal.dart';

/// The available ways [MealListController.meals] can be ordered.
enum MealSortOption { custom, nameAZ, nameZA, cookTimeAsc, favoritesFirst }

/// A "smart filter" that constrains which meals show up in the list and wheel.
enum MealFilter {
  quick('Quick (<30m)'),
  vegetarian('Vegetarian'),
  comfortFood('Comfort Food'),
  pantryFriendly('Pantry Friendly');

  const MealFilter(this.label);
  final String label;

  bool matches(Meal meal) {
    switch (this) {
      case MealFilter.quick:
        return meal.isQuick;
      case MealFilter.vegetarian:
        return meal.tags.contains(MealTag.vegetarian);
      case MealFilter.comfortFood:
        return meal.tags.contains(MealTag.comfortFood);
      case MealFilter.pantryFriendly:
        return meal.tags.contains(MealTag.pantryFriendly);
    }
  }
}

/// Owns the home-cooked meal roster: entries, favorites, recipe details, manual
/// ranking, sorting, and smart filters.
class MealListController extends ChangeNotifier {
  MealListController([List<String>? initialMeals])
      : _meals = [for (final name in initialMeals ?? const []) Meal(name: name)];

  static const int minMeals = 2;
  static const int maxNameLength = 40;

  final List<Meal> _meals;
  String? _error;
  MealSortOption _sortOption = MealSortOption.custom;
  final Set<MealFilter> _activeFilters = {};

  String? get error => _error;
  MealSortOption get sortOption => _sortOption;
  Set<MealFilter> get activeFilters => Set.unmodifiable(_activeFilters);
  bool get isAtMinimum => _meals.length <= minMeals;

  /// Meals matching the active filters, in the currently selected sort order. The
  /// manual/custom order is kept intact underneath, so switching back to "custom"
  /// restores the last ranking.
  List<Meal> get meals {
    var result = List<Meal>.of(_meals);
    if (_activeFilters.isNotEmpty) {
      result = result.where((meal) => _activeFilters.any((filter) => filter.matches(meal))).toList();
    }

    switch (_sortOption) {
      case MealSortOption.nameAZ:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case MealSortOption.nameZA:
        result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case MealSortOption.cookTimeAsc:
        result.sort((a, b) => (a.cookTimeMinutes ?? 1 << 30).compareTo(b.cookTimeMinutes ?? 1 << 30));
      case MealSortOption.favoritesFirst:
        result.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
      case MealSortOption.custom:
        break;
    }
    return List.unmodifiable(result);
  }

  void setSortOption(MealSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void toggleFilter(MealFilter filter) {
    if (!_activeFilters.remove(filter)) {
      _activeFilters.add(filter);
    }
    notifyListeners();
  }

  /// Adds [rawName] after trimming and validating it. Returns true on success.
  bool add(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty || name.length > maxNameLength) {
      _error = 'Enter a meal name up to $maxNameLength characters.';
      notifyListeners();
      return false;
    }
    if (_meals.any((meal) => meal.matchesName(name))) {
      _error = 'That meal is already on the list.';
      notifyListeners();
      return false;
    }
    _error = null;
    _meals.add(Meal(name: name));
    notifyListeners();
    return true;
  }

  /// Removes [meal] unless doing so would drop below [minMeals] entries.
  bool remove(Meal meal) {
    if (isAtMinimum) return false;
    _meals.remove(meal);
    notifyListeners();
    return true;
  }

  void toggleFavorite(Meal meal) {
    meal.isFavorite = !meal.isFavorite;
    notifyListeners();
  }

  /// Replaces [meal]'s recipe details.
  void updateMeal(
    Meal meal, {
    required List<String> ingredients,
    required String instructions,
    int? cookTimeMinutes,
    required Set<MealTag> tags,
  }) {
    meal.ingredients = ingredients;
    meal.instructions = instructions;
    meal.cookTimeMinutes = cookTimeMinutes;
    meal.tags = tags;
    notifyListeners();
  }

  /// Moves a meal from [oldIndex] to [newIndex] in the manual/custom ranking.
  void reorderCustom(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final meal = _meals.removeAt(oldIndex);
    _meals.insert(newIndex, meal);
    _sortOption = MealSortOption.custom;
    notifyListeners();
  }
}
