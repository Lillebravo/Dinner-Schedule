import 'package:flutter/material.dart';

import '../../controllers/meal_schedule_controller.dart';
import '../../l10n/app_locale.dart';
import '../../models/scheduled_dinner.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';

const _weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// A bottom sheet showing one day's scheduled dinner (or empty state), opened by
/// tapping a day in the monthly calendar grid.
class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    super.key,
    required this.day,
    required this.scheduleController,
    required this.onAddMeal,
    required this.onAddEatingOut,
  });

  final DateTime day;
  final MealScheduleController scheduleController;
  final VoidCallback onAddMeal;
  final VoidCallback onAddEatingOut;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedBuilder(
      animation: scheduleController,
      builder: (context, _) {
        final dinner = scheduleController.dinnerOn(day);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weekdayNames[day.weekday - 1]}, ${_monthNames[day.month - 1]} ${day.day}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.ink),
                ),
                const SizedBox(height: 16),
                if (dinner != null) ...[
                  Row(
                    children: [
                      Icon(dinner.type == DinnerType.homeCooked ? Icons.soup_kitchen_outlined : Icons.restaurant_outlined,
                          color: colors.coralDark),
                      const SizedBox(width: 8),
                      Expanded(child: Text(dinner.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    key: const Key('day-detail-clear'),
                    onPressed: () {
                      scheduleController.clearDinner(day);
                      Navigator.of(context).pop();
                    },
                    child: Text(tr(context, 'schedule.clearDinner')),
                  ),
                ] else
                  Text('Nothing scheduled yet.', style: TextStyle(color: colors.muted)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        key: const Key('day-detail-add-meal'),
                        label: tr(context, 'schedule.addMealButton'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onAddMeal();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('day-detail-eat-out'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onAddEatingOut();
                        },
                        child: Text(tr(context, 'schedule.eatOutButton')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
