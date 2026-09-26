import 'package:flutter/material.dart';

import '../controllers/food_list_controller.dart';
import '../controllers/meal_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../models/scheduled_dinner.dart';
import '../theme/app_theme.dart';
import '../utils/calendar_math.dart';
import '../widgets/common/section_intro.dart';
import '../widgets/schedule/day_detail_sheet.dart';
import '../widgets/schedule/day_dinner_card.dart';
import '../widgets/schedule/dinner_picker_sheet.dart';
import '../widgets/schedule/month_day_cell.dart';
import '../widgets/schedule/month_picker_sheet.dart';
import '../widgets/schedule/schedule_period_header.dart';
import '../widgets/schedule/week_picker_sheet.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdayHeadings = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// The view granularity for [MealPlanPage]'s schedule.
enum PlanViewMode { weekly, monthly }

/// The weekly/monthly dinner calendar: assign a home-cooked meal or a night out
/// to any day, jump forward/backward by week, month, or an exact pick, and drag
/// dinners between days to rearrange the schedule.
class MealPlanPage extends StatefulWidget {
  const MealPlanPage({
    super.key,
    required this.scheduleController,
    required this.mealListController,
    required this.foodListController,
  });

  final MealScheduleController scheduleController;
  final MealListController mealListController;
  final FoodListController foodListController;

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  PlanViewMode _mode = PlanViewMode.weekly;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    widget.scheduleController.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.scheduleController.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _stepPeriod(int direction) {
    setState(() {
      _focusedDay = _mode == PlanViewMode.weekly
          ? _focusedDay.add(Duration(days: 7 * direction))
          : DateTime(_focusedDay.year, _focusedDay.month + direction, 1);
    });
  }

  Future<void> _openPeriodPicker() async {
    if (_mode == PlanViewMode.weekly) {
      final picked = await showModalBottomSheet<DateTime>(
        context: context,
        builder: (context) => WeekPickerSheet(initialWeekStart: CalendarMath.startOfWeek(_focusedDay)),
      );
      if (picked != null) setState(() => _focusedDay = picked);
    } else {
      final picked = await showModalBottomSheet<DateTime>(
        context: context,
        builder: (context) => MonthPickerSheet(initialMonth: DateTime(_focusedDay.year, _focusedDay.month)),
      );
      if (picked != null) setState(() => _focusedDay = picked);
    }
  }

  Future<void> _pickDinnerOfType(DateTime day, DinnerType type) async {
    final dinner = await showModalBottomSheet<ScheduledDinner>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DinnerPickerSheet(
        mealListController: widget.mealListController,
        foodListController: widget.foodListController,
        initialTab: type,
      ),
    );
    if (dinner != null) widget.scheduleController.setDinner(day, dinner);
  }

  void _openDayDetail(DateTime day) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DayDetailSheet(
        day: day,
        scheduleController: widget.scheduleController,
        onAddMeal: () => _pickDinnerOfType(day, DinnerType.homeCooked),
        onAddEatingOut: () => _pickDinnerOfType(day, DinnerType.eatingOut),
      ),
    );
  }

  String get _periodLabel =>
      _mode == PlanViewMode.weekly ? 'Week ${CalendarMath.isoWeekNumber(_focusedDay)}' : _monthYearLabel(_focusedDay);

  String _monthYearLabel(DateTime day) => '${_monthNames[day.month - 1]} ${day.year}';

  /// Whether [_focusedDay] is already showing the week/month containing today.
  bool get _isCurrentPeriod {
    final today = DateTime.now();
    return _mode == PlanViewMode.weekly
        ? CalendarMath.isSameDay(CalendarMath.startOfWeek(_focusedDay), CalendarMath.startOfWeek(today))
        : CalendarMath.isSameMonth(_focusedDay, today);
  }

  void _jumpToCurrentPeriod() => setState(() => _focusedDay = DateTime.now());

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionIntro(
              eyebrow: 'MEAL PLANNING',
              headline: 'Plan your week of dinners.',
              subtitle: 'Assign a home-cooked meal or a night out to any day, then drag to rearrange.',
            ),
            const SizedBox(height: 32),
            Center(
              child: SegmentedButton<PlanViewMode>(
                key: const Key('plan-view-toggle'),
                segments: const [
                  ButtonSegment(value: PlanViewMode.weekly, label: Text('Weekly'), icon: Icon(Icons.view_week_outlined)),
                  ButtonSegment(value: PlanViewMode.monthly, label: Text('Monthly'), icon: Icon(Icons.calendar_view_month_outlined)),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) => setState(() => _mode = selection.first),
              ),
            ),
            const SizedBox(height: 20),
            SchedulePeriodHeader(
              label: _periodLabel,
              onPrevious: () => _stepPeriod(-1),
              onNext: () => _stepPeriod(1),
              onTapLabel: _openPeriodPicker,
            ),
            if (!_isCurrentPeriod)
              Center(
                child: TextButton(
                  key: const Key('jump-to-current-period'),
                  onPressed: _jumpToCurrentPeriod,
                  child: Text(_mode == PlanViewMode.weekly ? 'This week' : 'This month'),
                ),
              ),
            const SizedBox(height: 20),
            if (_mode == PlanViewMode.weekly) _buildWeekly(today) else _buildMonthly(today),
            const SizedBox(height: 12),
            const Text(
              'Long-press a scheduled dinner and drag it onto another day to swap them.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekly(DateTime today) {
    final days = CalendarMath.weekDays(_focusedDay);
    return Column(
      children: [
        for (final day in days) ...[
          DayDinnerCard(
            day: day,
            dinner: widget.scheduleController.dinnerOn(day),
            isToday: CalendarMath.isSameDay(day, today),
            onAddMeal: () => _pickDinnerOfType(day, DinnerType.homeCooked),
            onAddEatingOut: () => _pickDinnerOfType(day, DinnerType.eatingOut),
            onClear: () => widget.scheduleController.clearDinner(day),
            onDropDinner: (drag) => widget.scheduleController.moveDinner(drag.day, day),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildMonthly(DateTime today) {
    final days = CalendarMath.monthGrid(_focusedDay);
    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdayHeadings)
              Expanded(
                child: Center(
                  child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted, fontSize: 12)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 88),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            return MonthDayCell(
              day: day,
              dinner: widget.scheduleController.dinnerOn(day),
              inCurrentMonth: CalendarMath.isSameMonth(day, _focusedDay),
              isToday: CalendarMath.isSameDay(day, today),
              onTap: () => _openDayDetail(day),
              onDropDinner: (drag) => widget.scheduleController.moveDinner(drag.day, day),
            );
          },
        ),
      ],
    );
  }
}
