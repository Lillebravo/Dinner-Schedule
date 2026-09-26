import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/utils/calendar_math.dart';

void main() {
  group('CalendarMath', () {
    test('startOfWeek returns the Monday on or before the given day', () {
      // Wednesday, September 24, 2025.
      final wednesday = DateTime(2025, 9, 24);
      final monday = CalendarMath.startOfWeek(wednesday);
      expect(monday, DateTime(2025, 9, 22));

      // Already a Monday.
      expect(CalendarMath.startOfWeek(DateTime(2025, 9, 22)), DateTime(2025, 9, 22));
    });

    test('weekDays returns 7 consecutive days starting on Monday', () {
      final days = CalendarMath.weekDays(DateTime(2025, 9, 24));
      expect(days, hasLength(7));
      expect(days.first, DateTime(2025, 9, 22));
      expect(days.last, DateTime(2025, 9, 28));
      for (var i = 0; i < 7; i++) {
        expect(days[i].weekday, i + 1);
      }
    });

    test('isoWeekNumber matches known reference weeks', () {
      expect(CalendarMath.isoWeekNumber(DateTime(2025, 1, 1)), 1);
      expect(CalendarMath.isoWeekNumber(DateTime(2025, 9, 24)), 39);
      // Dec 31, 2024 falls in ISO week 1 of 2025.
      expect(CalendarMath.isoWeekNumber(DateTime(2024, 12, 31)), 1);
    });

    test('monthGrid produces 42 days covering the whole month, Monday-first', () {
      final grid = CalendarMath.monthGrid(DateTime(2025, 9, 15));
      expect(grid, hasLength(42));
      expect(grid.first.weekday, DateTime.monday);
      expect(grid.any((day) => CalendarMath.isSameDay(day, DateTime(2025, 9, 1))), isTrue);
      expect(grid.any((day) => CalendarMath.isSameDay(day, DateTime(2025, 9, 30))), isTrue);
    });

    test('isSameDay and isSameMonth compare only the relevant fields', () {
      expect(CalendarMath.isSameDay(DateTime(2025, 9, 24, 8), DateTime(2025, 9, 24, 20)), isTrue);
      expect(CalendarMath.isSameDay(DateTime(2025, 9, 24), DateTime(2025, 9, 25)), isFalse);
      expect(CalendarMath.isSameMonth(DateTime(2025, 9, 1), DateTime(2025, 9, 30)), isTrue);
      expect(CalendarMath.isSameMonth(DateTime(2025, 9, 30), DateTime(2025, 10, 1)), isFalse);
    });
  });
}
