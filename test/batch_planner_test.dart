import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/models/scheduled_dinner.dart';
import 'package:dishdash/utils/batch_planner.dart';

void main() {
  group('BatchPlanner.fillWeek', () {
    // Wednesday, September 24, 2025 - week runs Mon Sep 22 to Sun Sep 28.
    final weekAnchor = DateTime(2025, 9, 24);

    test('fills every day when nothing is scheduled', () {
      final assignments = BatchPlanner.fillWeek(
        weekAnchor: weekAnchor,
        mealNames: const ['Tacos', 'Stir-fry', 'Curry'],
        dinnerOn: (day) => null,
      );

      expect(assignments, hasLength(7));
      for (final dinner in assignments.values) {
        expect(dinner.type, DinnerType.homeCooked);
        expect(const ['Tacos', 'Stir-fry', 'Curry'], contains(dinner.title));
      }
    });

    test('never overwrites a day that already has a dinner', () {
      final monday = DateTime(2025, 9, 22);
      const existing = ScheduledDinner(title: 'Leftovers', type: DinnerType.eatingOut);

      final assignments = BatchPlanner.fillWeek(
        weekAnchor: weekAnchor,
        mealNames: const ['Tacos', 'Stir-fry'],
        dinnerOn: (day) => day == monday ? existing : null,
      );

      expect(assignments.containsKey(monday), isFalse);
      expect(assignments, hasLength(6));
    });

    test('does not repeat a meal when there are at least as many meals as empty days', () {
      final assignments = BatchPlanner.fillWeek(
        weekAnchor: weekAnchor,
        mealNames: const ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
        dinnerOn: (day) => null,
      );

      expect(assignments.values.map((d) => d.title).toSet(), hasLength(7));
    });

    test('cycles through meals when there are more empty days than meals', () {
      final assignments = BatchPlanner.fillWeek(
        weekAnchor: weekAnchor,
        mealNames: const ['Tacos'],
        dinnerOn: (day) => null,
      );

      expect(assignments, hasLength(7));
      expect(assignments.values.every((d) => d.title == 'Tacos'), isTrue);
    });

    test('returns nothing when there are no meals to pick from', () {
      final assignments = BatchPlanner.fillWeek(weekAnchor: weekAnchor, mealNames: const [], dinnerOn: (day) => null);
      expect(assignments, isEmpty);
    });

    test('returns nothing when the week is already fully scheduled', () {
      final assignments = BatchPlanner.fillWeek(
        weekAnchor: weekAnchor,
        mealNames: const ['Tacos'],
        dinnerOn: (day) => const ScheduledDinner(title: 'Something', type: DinnerType.homeCooked),
      );
      expect(assignments, isEmpty);
    });
  });
}
