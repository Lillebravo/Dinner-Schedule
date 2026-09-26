import 'package:flutter/material.dart';

import '../../controllers/meal_schedule_controller.dart';
import '../../models/scheduled_dinner.dart';
import '../../theme/app_theme.dart';
import 'date_picker_calendar_sheet.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// A bottom sheet for picking a day to add a dinner to. Lists the next
/// [daysAhead] days (today pinned first as "Tonight") and shows whichever
/// dinner is already scheduled on each one, so the user can see what they'd be
/// replacing before picking. Pops with the chosen [DateTime], or null if
/// dismissed.
class DayPickerSheet extends StatelessWidget {
  const DayPickerSheet({super.key, required this.scheduleController, this.daysAhead = 28});

  final MealScheduleController scheduleController;
  final int daysAhead;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = [for (var i = 0; i < daysAhead; i++) today.add(Duration(days: i))];

    return AnimatedBuilder(
      animation: scheduleController,
      builder: (context, _) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Add to schedule', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, fontSize: 16)),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: days.length + 1,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.line),
                  itemBuilder: (context, index) {
                    if (index == days.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextButton(
                          key: const Key('day-picker-custom-date'),
                          onPressed: () => _pickCustomDate(context, today),
                          child: const Text('Pick a different date...'),
                        ),
                      );
                    }
                    final day = days[index];
                    return _DayRow(
                      day: day,
                      isToday: index == 0,
                      dinner: scheduleController.dinnerOn(day),
                      onTap: () => Navigator.of(context).pop(day),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomDate(BuildContext context, DateTime today) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => DatePickerCalendarSheet(
        initialDate: today,
        firstDate: today.subtract(const Duration(days: 365)),
        lastDate: today.add(const Duration(days: 365 * 2)),
        scheduleController: scheduleController,
      ),
    );
    if (context.mounted && picked != null) Navigator.of(context).pop(picked);
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.isToday, required this.dinner, required this.onTap});

  final DateTime day;
  final bool isToday;
  final ScheduledDinner? dinner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheduled = dinner;
    return ListTile(
      key: Key('day-picker-option-${day.toIso8601String()}'),
      onTap: onTap,
      leading: _StatusDot(key: Key('day-picker-dot-${day.toIso8601String()}'), planned: scheduled != null),
      title: Text(
        isToday ? 'Tonight' : '${_weekdayNames[day.weekday - 1]}, ${_monthAbbreviations[day.month - 1]} ${day.day}',
        style: TextStyle(fontWeight: isToday ? FontWeight.w800 : FontWeight.w600),
      ),
      subtitle: scheduled == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(scheduled.type == DinnerType.homeCooked ? Icons.soup_kitchen_outlined : Icons.restaurant_outlined,
                    size: 14, color: AppColors.coralDark),
                const SizedBox(width: 4),
                Flexible(child: Text(scheduled.title, overflow: TextOverflow.ellipsis)),
              ],
            ),
      trailing: scheduled != null
          ? const Text('Already planned', key: Key('day-picker-already-planned'), style: TextStyle(color: AppColors.muted, fontSize: 11))
          : null,
    );
  }
}

/// A small filled dot when a day already has a dinner planned, or a hollow ring
/// when it's free, so occupancy reads at a glance without needing to read text.
class _StatusDot extends StatelessWidget {
  const _StatusDot({super.key, required this.planned});

  final bool planned;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: planned ? AppColors.coral : Colors.transparent,
            border: Border.all(color: planned ? AppColors.coral : AppColors.line, width: 1.5),
          ),
        ),
      ),
    );
  }
}
