import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/controllers/meal_list_controller.dart';
import 'package:dishdash/models/meal.dart';

void main() {
  group('MealListController', () {
    test('add trims names and rejects blanks, over-length, and duplicates', () {
      final controller = MealListController(['Tacos', 'Pasta']);

      expect(controller.add('  Ramen  '), isTrue);
      expect(controller.meals.map((m) => m.name), contains('Ramen'));

      expect(controller.add(''), isFalse);
      expect(controller.error, isNotNull);

      expect(controller.add('x' * 41), isFalse);

      expect(controller.add('tacos'), isFalse);
      expect(controller.error, 'That meal is already on the list.');
    });

    test('remove is blocked at the minimum of two meals', () {
      final controller = MealListController(['Tacos', 'Pasta']);
      expect(controller.isAtMinimum, isTrue);
      expect(controller.remove(controller.meals.first), isFalse);
      expect(controller.meals, hasLength(2));
    });

    test('toggleFavorite flips a meal in place', () {
      final controller = MealListController(['Tacos', 'Pasta']);
      final meal = controller.meals.first;

      expect(meal.isFavorite, isFalse);
      controller.toggleFavorite(meal);
      expect(meal.isFavorite, isTrue);
      controller.toggleFavorite(meal);
      expect(meal.isFavorite, isFalse);
    });

    test('updateMeal replaces recipe details', () {
      final controller = MealListController(['Tacos', 'Pasta']);
      final meal = controller.meals.first;

      controller.updateMeal(
        meal,
        ingredients: ['Tortillas', 'Beef'],
        instructions: 'Cook it.',
        cookTimeMinutes: 20,
        tags: {MealTag.pantryFriendly},
      );

      expect(meal.ingredients, ['Tortillas', 'Beef']);
      expect(meal.instructions, 'Cook it.');
      expect(meal.cookTimeMinutes, 20);
      expect(meal.tags, {MealTag.pantryFriendly});
    });

    test('sorting by name and cook time leaves the custom order untouched underneath', () {
      final controller = MealListController(['Zucchini Boats', 'Apple Pie', 'Mango Salad']);
      controller.updateMeal(controller.meals[0], ingredients: const [], instructions: '', cookTimeMinutes: 30, tags: const {});
      controller.updateMeal(controller.meals[1], ingredients: const [], instructions: '', cookTimeMinutes: 10, tags: const {});
      controller.updateMeal(controller.meals[2], ingredients: const [], instructions: '', cookTimeMinutes: 20, tags: const {});

      controller.setSortOption(MealSortOption.nameAZ);
      expect(controller.meals.map((m) => m.name), ['Apple Pie', 'Mango Salad', 'Zucchini Boats']);

      controller.setSortOption(MealSortOption.nameZA);
      expect(controller.meals.map((m) => m.name), ['Zucchini Boats', 'Mango Salad', 'Apple Pie']);

      controller.setSortOption(MealSortOption.cookTimeAsc);
      expect(controller.meals.map((m) => m.name), ['Apple Pie', 'Mango Salad', 'Zucchini Boats']);

      controller.setSortOption(MealSortOption.custom);
      expect(controller.meals.map((m) => m.name), ['Zucchini Boats', 'Apple Pie', 'Mango Salad']);
    });

    test('favoritesFirst sorts favorited meals ahead of the rest', () {
      final controller = MealListController(['Tacos', 'Pasta', 'Curry']);
      controller.toggleFavorite(controller.meals[2]);

      controller.setSortOption(MealSortOption.favoritesFirst);
      expect(controller.meals.first.name, 'Curry');
    });

    test('reorderCustom moves a meal and switches back to custom order', () {
      final controller = MealListController(['Tacos', 'Pasta', 'Curry']);
      controller.setSortOption(MealSortOption.nameAZ);

      controller.reorderCustom(0, 2);

      expect(controller.sortOption, MealSortOption.custom);
      expect(controller.meals.map((m) => m.name), ['Pasta', 'Tacos', 'Curry']);
    });

    test('cycleSort cycles name and cook time through ascending, descending, then no sort', () {
      final controller = MealListController(['Tacos', 'Pasta']);

      controller.cycleSort(MealSortCriterion.name);
      expect(controller.sortOption, MealSortOption.nameAZ);
      expect(controller.activeSortCriterion, MealSortCriterion.name);
      expect(controller.isSortDescending, isFalse);

      controller.cycleSort(MealSortCriterion.name);
      expect(controller.sortOption, MealSortOption.nameZA);
      expect(controller.isSortDescending, isTrue);

      controller.cycleSort(MealSortCriterion.name);
      expect(controller.sortOption, MealSortOption.custom);
      expect(controller.activeSortCriterion, isNull);

      controller.cycleSort(MealSortCriterion.cookTime);
      expect(controller.sortOption, MealSortOption.cookTimeAsc);

      controller.cycleSort(MealSortCriterion.cookTime);
      expect(controller.sortOption, MealSortOption.cookTimeDesc);

      controller.cycleSort(MealSortCriterion.cookTime);
      expect(controller.sortOption, MealSortOption.custom);
    });

    test('cycleSort switching criteria starts the new one fresh at ascending', () {
      final controller = MealListController(['Tacos', 'Pasta']);

      controller.cycleSort(MealSortCriterion.name);
      controller.cycleSort(MealSortCriterion.name);
      expect(controller.sortOption, MealSortOption.nameZA);

      controller.cycleSort(MealSortCriterion.cookTime);
      expect(controller.sortOption, MealSortOption.cookTimeAsc);
    });

    test('cycleSort toggles favorites first on and off', () {
      final controller = MealListController(['Tacos', 'Pasta']);

      controller.cycleSort(MealSortCriterion.favorites);
      expect(controller.sortOption, MealSortOption.favoritesFirst);

      controller.cycleSort(MealSortCriterion.favorites);
      expect(controller.sortOption, MealSortOption.custom);
    });

    test('quick filter matches meals under 30 minutes', () {
      final controller = MealListController(['Tacos', 'Pasta', 'Curry']);
      controller.updateMeal(controller.meals[0], ingredients: const [], instructions: '', cookTimeMinutes: 15, tags: const {});
      controller.updateMeal(controller.meals[1], ingredients: const [], instructions: '', cookTimeMinutes: 45, tags: const {});

      controller.toggleFilter(MealFilter.quick);

      expect(controller.activeFilters, {MealFilter.quick});
      expect(controller.meals.map((m) => m.name), ['Tacos']);
    });

    test('vegan and pescatarian filters match their respective tags', () {
      final controller = MealListController(['Tacos', 'Pasta', 'Curry']);
      controller.updateMeal(controller.meals[0], ingredients: const [], instructions: '', tags: {MealTag.vegan});
      controller.updateMeal(controller.meals[1], ingredients: const [], instructions: '', tags: {MealTag.pescatarian});
      controller.updateMeal(controller.meals[2], ingredients: const [], instructions: '', tags: const {});

      controller.toggleFilter(MealFilter.vegan);
      expect(controller.meals.map((m) => m.name), ['Tacos']);

      controller.toggleFilter(MealFilter.pescatarian);
      expect(controller.meals.map((m) => m.name).toSet(), {'Tacos', 'Pasta'});
    });

    test('tag filters match any selected tag (OR) and toggle off correctly', () {
      final controller = MealListController(['Tacos', 'Pasta', 'Curry']);
      controller.updateMeal(controller.meals[0], ingredients: const [], instructions: '', tags: {MealTag.vegetarian});
      controller.updateMeal(controller.meals[1], ingredients: const [], instructions: '', tags: {MealTag.comfortFood});
      controller.updateMeal(controller.meals[2], ingredients: const [], instructions: '', tags: const {});

      controller.toggleFilter(MealFilter.vegetarian);
      controller.toggleFilter(MealFilter.comfortFood);
      expect(controller.meals.map((m) => m.name).toSet(), {'Tacos', 'Pasta'});

      controller.toggleFilter(MealFilter.vegetarian);
      expect(controller.meals.map((m) => m.name), ['Pasta']);

      controller.toggleFilter(MealFilter.comfortFood);
      expect(controller.activeFilters, isEmpty);
      expect(controller.meals, hasLength(3));
    });
  });
}
