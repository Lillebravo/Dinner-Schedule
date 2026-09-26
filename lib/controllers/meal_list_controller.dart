import 'package:flutter/foundation.dart';

import '../models/meal.dart';

/// The available ways [MealListController.meals] can be ordered.
enum MealSortOption { custom, nameAZ, nameZA, cookTimeAsc, cookTimeDesc, favoritesFirst }

/// A sortable criterion in the UI. Each maps to a pair of [MealSortOption]s
/// (ascending/descending) that a single button cycles through, except
/// [favorites] which only has one direction.
enum MealSortCriterion { name, cookTime, favorites }

/// A "smart filter" that constrains which meals show up in the list and wheel.
enum MealFilter {
  quick('Quick (<30m)'),
  vegetarian('Vegetarian'),
  vegan('Vegan'),
  pescatarian('Pescatarian'),
  glutenFree('Gluten-Free'),
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
      case MealFilter.vegan:
        return meal.tags.contains(MealTag.vegan);
      case MealFilter.pescatarian:
        return meal.tags.contains(MealTag.pescatarian);
      case MealFilter.glutenFree:
        return meal.tags.contains(MealTag.glutenFree);
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

  /// The sort criterion currently in effect, or null when unsorted (custom order).
  MealSortCriterion? get activeSortCriterion => switch (_sortOption) {
        MealSortOption.nameAZ || MealSortOption.nameZA => MealSortCriterion.name,
        MealSortOption.cookTimeAsc || MealSortOption.cookTimeDesc => MealSortCriterion.cookTime,
        MealSortOption.favoritesFirst => MealSortCriterion.favorites,
        MealSortOption.custom => null,
      };

  /// Whether the active sort criterion is currently descending.
  bool get isSortDescending => _sortOption == MealSortOption.nameZA || _sortOption == MealSortOption.cookTimeDesc;

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
      case MealSortOption.cookTimeDesc:
        result.sort((a, b) => (b.cookTimeMinutes ?? -(1 << 30)).compareTo(a.cookTimeMinutes ?? -(1 << 30)));
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

  /// Finds a meal by name (case-insensitive), ignoring active filters/sort.
  /// Used to resolve a scheduled dinner's title back to its recipe details.
  Meal? findByName(String name) {
    for (final meal in _meals) {
      if (meal.matchesName(name)) return meal;
    }
    return null;
  }

  /// Cycles [criterion] through ascending → descending → no sort (custom order).
  /// [MealSortCriterion.favorites] only has one direction, so it just toggles on/off.
  /// Selecting a different criterion than the one currently active starts it fresh (ascending).
  void cycleSort(MealSortCriterion criterion) {
    switch (criterion) {
      case MealSortCriterion.name:
        _sortOption = switch (_sortOption) {
          MealSortOption.nameAZ => MealSortOption.nameZA,
          MealSortOption.nameZA => MealSortOption.custom,
          _ => MealSortOption.nameAZ,
        };
      case MealSortCriterion.cookTime:
        _sortOption = switch (_sortOption) {
          MealSortOption.cookTimeAsc => MealSortOption.cookTimeDesc,
          MealSortOption.cookTimeDesc => MealSortOption.custom,
          _ => MealSortOption.cookTimeAsc,
        };
      case MealSortCriterion.favorites:
        _sortOption = _sortOption == MealSortOption.favoritesFirst ? MealSortOption.custom : MealSortOption.favoritesFirst;
    }
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
