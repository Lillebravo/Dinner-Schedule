import '../controllers/meal_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../models/scheduled_dinner.dart';
import '../models/shopping_list_item.dart';
import 'calendar_math.dart';

/// Derives a week's shopping list from whatever home-cooked dinners are on the
/// schedule that week, kept free of Flutter widgets so it can be unit tested
/// directly (mirrors [CalendarMath]).
class ShoppingListMath {
  const ShoppingListMath._();

  /// Every ingredient needed by the home-cooked dinners scheduled in the week
  /// containing [weekAnchor], consolidated by ingredient name (case/whitespace
  /// insensitive) and sorted alphabetically. Eating-out dinners and days with
  /// nothing scheduled are skipped. Meals that no longer exist in
  /// [mealListController] (e.g. deleted after being scheduled) are skipped too.
  ///
  /// Each day's ingredients are scaled by that day's own
  /// [ScheduledDinner.servings] against the recipe's base [Meal.servings]
  /// before being added up - so planning a bigger portion for one night (e.g.
  /// doubling up for guests) buys the right amount for that night specifically.
  ///
  /// When every contributing occurrence has a usable (scaled) quantity in the
  /// same unit, those quantities are summed into the item's
  /// [ShoppingListItem.totalQuantity] (e.g. 2 onions + 3 onions = 5 onions).
  /// Otherwise (a missing quantity, or mismatched units) the item just reports
  /// how many recipes need it via [ShoppingListItem.count], same as before.
  static List<ShoppingListItem> forWeek({
    required DateTime weekAnchor,
    required MealScheduleController scheduleController,
    required MealListController mealListController,
  }) {
    final counts = <String, int>{};
    final names = <String, String>{};
    final mealNames = <String, List<String>>{};
    final quantitySums = <String, double>{};
    final quantityUnits = <String, String>{};
    final quantityUsable = <String, bool>{};

    for (final day in CalendarMath.weekDays(weekAnchor)) {
      final dinner = scheduleController.dinnerOn(day);
      if (dinner == null || dinner.type != DinnerType.homeCooked) continue;
      final meal = mealListController.findByName(dinner.title);
      if (meal == null) continue;

      final scaleFactor = dinner.servings / meal.servings;

      for (final rawIngredient in meal.ingredients) {
        final ingredient = rawIngredient.scaled(scaleFactor);
        final trimmed = ingredient.name.trim();
        if (trimmed.isEmpty) continue;
        final key = trimmed.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
        names[key] ??= trimmed;
        (mealNames[key] ??= []).add(meal.name);

        final quantity = ingredient.quantity;
        final unit = ingredient.unit.trim().toLowerCase();
        if (quantity == null) {
          quantityUsable[key] = false;
        } else if (!quantityUsable.containsKey(key)) {
          quantitySums[key] = quantity;
          quantityUnits[key] = unit;
          quantityUsable[key] = true;
        } else if (quantityUsable[key] == true) {
          if (quantityUnits[key] == unit) {
            quantitySums[key] = quantitySums[key]! + quantity;
          } else {
            quantityUsable[key] = false;
          }
        }
      }
    }

    final items = [
      for (final key in counts.keys)
        ShoppingListItem(
          name: names[key]!,
          count: counts[key]!,
          mealNames: mealNames[key]!,
          totalQuantity: quantityUsable[key] == true ? quantitySums[key] : null,
          unit: quantityUsable[key] == true ? quantityUnits[key]! : '',
        ),
    ];
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(items);
  }
}
