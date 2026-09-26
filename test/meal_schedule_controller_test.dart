import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/controllers/meal_schedule_controller.dart';
import 'package:dishdash/models/scheduled_dinner.dart';

void main() {
  group('MealScheduleController', () {
    test('setDinner assigns a dinner, ignoring time-of-day', () {
      final controller = MealScheduleController();
      const dinner = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked);

      controller.setDinner(DateTime(2025, 9, 24, 18, 30), dinner);

      expect(controller.dinnerOn(DateTime(2025, 9, 24)), dinner);
      expect(controller.dinnerOn(DateTime(2025, 9, 24, 8)), dinner);
      expect(controller.dinnerOn(DateTime(2025, 9, 25)), isNull);
    });

    test('setDinner replaces whatever was already scheduled', () {
      final controller = MealScheduleController();
      final day = DateTime(2025, 9, 24);

      controller.setDinner(day, const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked));
      controller.setDinner(day, const ScheduledDinner(title: 'Sushi Bar', type: DinnerType.eatingOut));

      expect(controller.dinnerOn(day), const ScheduledDinner(title: 'Sushi Bar', type: DinnerType.eatingOut));
    });

    test('clearDinner removes the dinner scheduled for a day', () {
      final controller = MealScheduleController();
      final day = DateTime(2025, 9, 24);
      controller.setDinner(day, const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked));

      controller.clearDinner(day);

      expect(controller.dinnerOn(day), isNull);
    });

    test('moveDinner relocates a dinner to an empty day', () {
      final controller = MealScheduleController();
      final monday = DateTime(2025, 9, 22);
      final tuesday = DateTime(2025, 9, 23);
      const dinner = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked);
      controller.setDinner(monday, dinner);

      controller.moveDinner(monday, tuesday);

      expect(controller.dinnerOn(monday), isNull);
      expect(controller.dinnerOn(tuesday), dinner);
    });

    test('moveDinner swaps dinners when the target day already has one', () {
      final controller = MealScheduleController();
      final monday = DateTime(2025, 9, 22);
      final tuesday = DateTime(2025, 9, 23);
      const mondayDinner = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked);
      const tuesdayDinner = ScheduledDinner(title: 'Sushi Bar', type: DinnerType.eatingOut);
      controller.setDinner(monday, mondayDinner);
      controller.setDinner(tuesday, tuesdayDinner);

      controller.moveDinner(monday, tuesday);

      expect(controller.dinnerOn(monday), tuesdayDinner);
      expect(controller.dinnerOn(tuesday), mondayDinner);
    });

    test('moveDinner is a no-op when the source day has nothing scheduled', () {
      final controller = MealScheduleController();
      final monday = DateTime(2025, 9, 22);
      final tuesday = DateTime(2025, 9, 23);
      const tuesdayDinner = ScheduledDinner(title: 'Sushi Bar', type: DinnerType.eatingOut);
      controller.setDinner(tuesday, tuesdayDinner);

      controller.moveDinner(monday, tuesday);

      expect(controller.dinnerOn(tuesday), tuesdayDinner);
      expect(controller.dinnerOn(monday), isNull);
    });
  });
}
