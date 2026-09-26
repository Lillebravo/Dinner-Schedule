import 'package:flutter/material.dart';

import '../../controllers/meal_schedule_controller.dart';
import '../../l10n/app_locale.dart';
import '../../models/scheduled_dinner.dart';
import '../../theme/app_theme.dart';
import 'day_picker_sheet.dart';

/// Adds a home-cooked meal or eating-out pick to the meal schedule, for tonight
/// or a chosen day. Shared by the wheel pages (once a winner is picked) and the
/// meals list (to schedule a meal directly), as a full labeled button or a
/// compact icon button.
class AddToScheduleButton extends StatelessWidget {
  const AddToScheduleButton({
    super.key,
    required this.title,
    required this.type,
    required this.scheduleController,
    this.compact = false,
  });

  final String title;
  final DinnerType type;
  final MealScheduleController scheduleController;
  final bool compact;

  Future<void> _addToSchedule(BuildContext context) async {
    final day = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DayPickerSheet(scheduleController: scheduleController),
    );
    if (day == null) return;
    scheduleController.setDinner(day, ScheduledDinner(title: title, type: type));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'schedule.added', {'title': title}))));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        onPressed: () => _addToSchedule(context),
        icon: const Icon(Icons.calendar_today_outlined, size: 20),
        color: AppColors.of(context).muted,
        tooltip: tr(context, 'schedule.addTooltip', {'title': title}),
      );
    }
    return TextButton.icon(
      key: const Key('add-to-schedule-button'),
      onPressed: () => _addToSchedule(context),
      icon: const Icon(Icons.calendar_today_outlined, size: 18),
      label: Text(tr(context, 'schedule.addButton')),
    );
  }
}
