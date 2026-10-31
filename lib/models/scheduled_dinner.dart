import 'meal.dart';

/// How a scheduled dinner will happen: cooked at home or eaten out.
enum DinnerType { homeCooked, eatingOut }

/// A dinner assigned to a specific calendar day in the meal schedule.
class ScheduledDinner {
  const ScheduledDinner({required this.title, required this.type, this.servings = Meal.defaultServings});

  final String title;
  final DinnerType type;

  /// How many portions this particular day's dinner is planned for - may
  /// differ from the recipe's own base [Meal.servings] (e.g. doubling up for
  /// guests), and is what the shopping list scales that day's ingredients by.
  final int servings;

  /// A copy of this dinner with [servings] replaced, used when the user
  /// adjusts the planned serving count from the meal planner.
  ScheduledDinner copyWith({int? servings}) => ScheduledDinner(title: title, type: type, servings: servings ?? this.servings);

  @override
  bool operator ==(Object other) =>
      other is ScheduledDinner && other.title == title && other.type == type && other.servings == servings;

  @override
  int get hashCode => Object.hash(title, type, servings);

  @override
  String toString() => title;
}
