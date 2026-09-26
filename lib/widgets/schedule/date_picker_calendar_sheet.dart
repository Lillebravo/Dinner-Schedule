import 'package:flutter/material.dart';

import '../../controllers/meal_schedule_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/calendar_math.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// A compact single-month calendar bottom sheet for picking a custom date,
/// used as the "Pick a different date..." fallback in [DayPickerSheet]. Unlike
/// the stock Material `showDatePicker`, each day shows a small checkmark badge
/// when [scheduleController] already has a dinner planned that day, so the
/// user can see at a glance which dates are already taken. Tapping a
/// selectable day immediately pops the sheet with that [DateTime].
class DatePickerCalendarSheet extends StatefulWidget {
  const DatePickerCalendarSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.scheduleController,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final MealScheduleController scheduleController;

  @override
  State<DatePickerCalendarSheet> createState() => _DatePickerCalendarSheetState();
}

class _DatePickerCalendarSheetState extends State<DatePickerCalendarSheet> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  bool _isSelectable(DateTime day) => !day.isBefore(widget.firstDate) && !day.isAfter(widget.lastDate);

  void _changeMonth(int delta) => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta));

  @override
  Widget build(BuildContext context) {
    final days = CalendarMath.monthGrid(_focusedMonth);
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    return AnimatedBuilder(
      animation: widget.scheduleController,
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: const Key('date-picker-previous-month'),
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, fontSize: 16),
                  ),
                  IconButton(
                    key: const Key('date-picker-next-month'),
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final label in _weekdayHeaders)
                    Expanded(
                      child: Center(
                        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.muted, fontSize: 12)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 44),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final inCurrentMonth = CalendarMath.isSameMonth(day, _focusedMonth);
                  final selectable = inCurrentMonth && _isSelectable(day);
                  return _DateCell(
                    key: Key('date-picker-day-${day.toIso8601String()}'),
                    label: '${day.day}',
                    isToday: CalendarMath.isSameDay(day, todayNormalized),
                    inCurrentMonth: inCurrentMonth,
                    planned: widget.scheduleController.dinnerOn(day) != null,
                    onTap: selectable ? () => Navigator.of(context).pop(day) : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    super.key,
    required this.label,
    required this.isToday,
    required this.inCurrentMonth,
    required this.planned,
    required this.onTap,
  });

  final String label;
  final bool isToday;
  final bool inCurrentMonth;
  final bool planned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: isToday ? AppColors.coral : Colors.transparent, width: 1.5)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  color: onTap == null ? AppColors.line : AppColors.ink,
                ),
              ),
              if (planned)
                const Positioned(
                  bottom: 2,
                  child: Icon(Icons.check_circle, size: 11, color: AppColors.coral),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
