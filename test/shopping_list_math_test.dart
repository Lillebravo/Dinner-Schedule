import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/controllers/meal_list_controller.dart';
import 'package:dishdash/controllers/meal_schedule_controller.dart';
import 'package:dishdash/models/ingredient.dart';
import 'package:dishdash/models/scheduled_dinner.dart';
import 'package:dishdash/utils/shopping_list_math.dart';

void main() {
  group('ShoppingListMath.forWeek', () {
    // Wednesday, September 24, 2025 - week runs Mon Sep 22 to Sun Sep 28.
    final weekAnchor = DateTime(2025, 9, 24);

    test('sums matching-unit quantities across meals into totalQuantity', () {
      final mealListController = MealListController(['Tacos', 'Soup']);
      final scheduleController = MealScheduleController();

      mealListController.updateMeal(
        mealListController.meals[0],
        ingredients: [Ingredient(quantity: 2, name: 'Onion')],
        instructions: '',
        tags: const {},
      );
      mealListController.updateMeal(
        mealListController.meals[1],
        ingredients: [Ingredient(quantity: 3, name: 'onion')],
        instructions: '',
        tags: const {},
      );
      scheduleController.setDinner(DateTime(2025, 9, 22), const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked));
      scheduleController.setDinner(DateTime(2025, 9, 23), const ScheduledDinner(title: 'Soup', type: DinnerType.homeCooked));

      final items = ShoppingListMath.forWeek(weekAnchor: weekAnchor, scheduleController: scheduleController, mealListController: mealListController);

      expect(items, hasLength(1));
      expect(items.first.name, 'Onion');
      expect(items.first.totalQuantity, 5);
      expect(items.first.count, 2);
    });

    test('falls back to a plain count when units differ', () {
      final mealListController = MealListController(['Tacos', 'Soup']);
      final scheduleController = MealScheduleController();

      mealListController.updateMeal(
        mealListController.meals[0],
        ingredients: [Ingredient(quantity: 2, unit: 'cups', name: 'Broth')],
        instructions: '',
        tags: const {},
      );
      mealListController.updateMeal(
        mealListController.meals[1],
        ingredients: [Ingredient(quantity: 1, unit: 'tbsp', name: 'Broth')],
        instructions: '',
        tags: const {},
      );
      scheduleController.setDinner(DateTime(2025, 9, 22), const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked));
      scheduleController.setDinner(DateTime(2025, 9, 23), const ScheduledDinner(title: 'Soup', type: DinnerType.homeCooked));

      final items = ShoppingListMath.forWeek(weekAnchor: weekAnchor, scheduleController: scheduleController, mealListController: mealListController);

      expect(items, hasLength(1));
      expect(items.first.totalQuantity, isNull);
      expect(items.first.count, 2);
    });

    test('falls back to a plain count when any contributing recipe omits the quantity', () {
      final mealListController = MealListController(['Tacos', 'Soup']);
      final scheduleController = MealScheduleController();

      mealListController.updateMeal(
        mealListController.meals[0],
        ingredients: [Ingredient(quantity: 2, name: 'Onion')],
        instructions: '',
        tags: const {},
      );
      mealListController.updateMeal(
        mealListController.meals[1],
        ingredients: [Ingredient(name: 'Onion')],
        instructions: '',
        tags: const {},
      );
      scheduleController.setDinner(DateTime(2025, 9, 22), const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked));
      scheduleController.setDinner(DateTime(2025, 9, 23), const ScheduledDinner(title: 'Soup', type: DinnerType.homeCooked));

      final items = ShoppingListMath.forWeek(weekAnchor: weekAnchor, scheduleController: scheduleController, mealListController: mealListController);

      expect(items, hasLength(1));
      expect(items.first.totalQuantity, isNull);
      expect(items.first.count, 2);
    });

    test('scales ingredient quantities by that day\'s planned servings against the recipe\'s base servings', () {
      final mealListController = MealListController(['Tacos']);
      final scheduleController = MealScheduleController();

      // Recipe is written for 4 servings...
      mealListController.updateMeal(
        mealListController.meals[0],
        ingredients: [Ingredient(quantity: 4, unit: 'g', name: 'Onion')],
        instructions: '',
        tags: const {},
        servings: 4,
      );
      // ...but this specific night is planned for 8 (double).
      scheduleController.setDinner(
        DateTime(2025, 9, 22),
        const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 8),
      );

      final items = ShoppingListMath.forWeek(weekAnchor: weekAnchor, scheduleController: scheduleController, mealListController: mealListController);

      expect(items, hasLength(1));
      expect(items.first.totalQuantity, 8);
    });

    test('scales each occurrence independently before summing', () {
      final mealListController = MealListController(['Tacos']);
      final scheduleController = MealScheduleController();

      mealListController.updateMeal(
        mealListController.meals[0],
        ingredients: [Ingredient(quantity: 2, unit: 'g', name: 'Onion')],
        instructions: '',
        tags: const {},
        servings: 2,
      );
      // Monday at the recipe's own 2 servings (factor 1x -> 2g), Thursday
      // doubled to 4 servings (factor 2x -> 4g): 2 + 4 = 6.
      scheduleController.setDinner(DateTime(2025, 9, 22), const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 2));
      scheduleController.setDinner(DateTime(2025, 9, 25), const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 4));

      final items = ShoppingListMath.forWeek(weekAnchor: weekAnchor, scheduleController: scheduleController, mealListController: mealListController);

      expect(items, hasLength(1));
      expect(items.first.totalQuantity, 6);
    });
  });
}
