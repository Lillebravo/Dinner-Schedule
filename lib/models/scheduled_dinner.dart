/// How a scheduled dinner will happen: cooked at home or eaten out.
enum DinnerType { homeCooked, eatingOut }

/// A dinner assigned to a specific calendar day in the meal schedule.
class ScheduledDinner {
  const ScheduledDinner({required this.title, required this.type});

  final String title;
  final DinnerType type;

  @override
  bool operator ==(Object other) => other is ScheduledDinner && other.title == title && other.type == type;

  @override
  int get hashCode => Object.hash(title, type);

  @override
  String toString() => title;
}
