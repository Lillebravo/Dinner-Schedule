/// Pure date/calendar geometry helpers for the meal-planning schedule, kept free
/// of Flutter widgets so they can be unit tested directly.
class CalendarMath {
  const CalendarMath._();

  /// Midnight of the Monday on or before [day].
  static DateTime startOfWeek(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  /// The 7 days (Monday-Sunday) of the week containing [day].
  static List<DateTime> weekDays(DateTime day) {
    final start = startOfWeek(day);
    return [for (var i = 0; i < 7; i++) start.add(Duration(days: i))];
  }

  /// ISO-8601 week number for [day]. Uses the "Thursday of this week" trick:
  /// the ISO week always belongs to whichever year owns that Thursday, which
  /// sidesteps having to special-case year boundaries directly.
  static int isoWeekNumber(DateTime day) {
    final thursday = startOfWeek(day).add(const Duration(days: 3));
    final dayOfYear = thursday.difference(DateTime(thursday.year, 1, 1)).inDays + 1;
    return ((dayOfYear - 1) / 7).floor() + 1;
  }

  /// A full display grid (6 rows of 7 days = 42 cells, Monday-first) for the
  /// month containing [day], including the leading/trailing days of adjacent
  /// months needed to fill whole weeks.
  static List<DateTime> monthGrid(DateTime day) {
    final firstOfMonth = DateTime(day.year, day.month, 1);
    final gridStart = startOfWeek(firstOfMonth);
    return [for (var i = 0; i < 42; i++) gridStart.add(Duration(days: i))];
  }

  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;
}
