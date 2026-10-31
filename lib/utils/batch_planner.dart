import 'dart:math';

import '../models/scheduled_dinner.dart';
import 'calendar_math.dart';

/// Pure logic for auto-filling empty days in a week's schedule, kept free of
/// Flutter widgets so it can be unit tested directly (mirrors
/// [CalendarMath]/[ShoppingListMath]).
class BatchPlanner {
  const BatchPlanner._();

  /// Assigns a home-cooked meal from [mealNames] to every day in the week
  /// containing [weekAnchor] that doesn't already have something scheduled
  /// (per [dinnerOn]) - existing dinners are never overwritten. Meals are
  /// shuffled and cycled through so a week isn't filled with the same meal
  /// repeatedly, with no repeats at all as long as there are at least as many
  /// distinct meals as empty days. Returns only the newly-assigned days, so
  /// the caller can apply them (and know how many it filled); an empty map
  /// means there was nothing to do (no meals to pick from, or no empty days).
  static Map<DateTime, ScheduledDinner> fillWeek({
    required DateTime weekAnchor,
    required List<String> mealNames,
    required ScheduledDinner? Function(DateTime day) dinnerOn,
    Random? random,
  }) {
    if (mealNames.isEmpty) return {};
    final emptyDays = [for (final day in CalendarMath.weekDays(weekAnchor)) if (dinnerOn(day) == null) day];
    if (emptyDays.isEmpty) return {};

    final shuffledMeals = List<String>.of(mealNames)..shuffle(random ?? Random());
    return {
      for (var i = 0; i < emptyDays.length; i++)
        emptyDays[i]: ScheduledDinner(title: shuffledMeals[i % shuffledMeals.length], type: DinnerType.homeCooked),
    };
  }
}
