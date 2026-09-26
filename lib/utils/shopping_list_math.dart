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
  /// containing [weekAnchor], consolidated by ingredient text (case/whitespace
  /// insensitive) and sorted alphabetically. Eating-out dinners and days with
  /// nothing scheduled are skipped. Meals that no longer exist in
  /// [mealListController] (e.g. deleted after being scheduled) are skipped too.
  static List<ShoppingListItem> forWeek({
    required DateTime weekAnchor,
    required MealScheduleController scheduleController,
    required MealListController mealListController,
  }) {
    final counts = <String, int>{};
    final names = <String, String>{};
    final mealNames = <String, List<String>>{};

    for (final day in CalendarMath.weekDays(weekAnchor)) {
      final dinner = scheduleController.dinnerOn(day);
      if (dinner == null || dinner.type != DinnerType.homeCooked) continue;
      final meal = mealListController.findByName(dinner.title);
      if (meal == null) continue;

      for (final ingredient in meal.ingredients) {
        final trimmed = ingredient.trim();
        if (trimmed.isEmpty) continue;
        final key = trimmed.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
        names[key] ??= trimmed;
        (mealNames[key] ??= []).add(meal.name);
      }
    }

    final items = [
      for (final key in counts.keys) ShoppingListItem(name: names[key]!, count: counts[key]!, mealNames: mealNames[key]!),
    ];
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(items);
  }
}
