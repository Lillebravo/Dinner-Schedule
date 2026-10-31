import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/models/scheduled_dinner.dart';

void main() {
  group('ScheduledDinner', () {
    test('defaults to 4 servings', () {
      const dinner = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked);
      expect(dinner.servings, 4);
    });

    test('copyWith replaces only servings', () {
      const dinner = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 4);
      final doubled = dinner.copyWith(servings: 8);

      expect(doubled.servings, 8);
      expect(doubled.title, 'Tacos');
      expect(doubled.type, DinnerType.homeCooked);
    });

    test('copyWith with no argument keeps the same servings', () {
      const dinner = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 6);
      expect(dinner.copyWith().servings, 6);
    });

    test('equality accounts for servings', () {
      const a = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 4);
      const b = ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 6);
      expect(a == b, isFalse);
      expect(a, const ScheduledDinner(title: 'Tacos', type: DinnerType.homeCooked, servings: 4));
    });
  });
}
