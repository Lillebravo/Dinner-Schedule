import 'package:flutter/material.dart';

import '../controllers/meal_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../controllers/shopping_list_controller.dart';
import '../l10n/app_locale.dart';
import '../models/shopping_list_item.dart';
import '../theme/app_theme.dart';
import '../utils/calendar_math.dart';
import '../utils/shopping_list_math.dart';
import '../widgets/common/count_badge.dart';
import '../widgets/common/panel_header.dart';
import '../widgets/schedule/schedule_period_header.dart';
import '../widgets/schedule/week_picker_sheet.dart';

/// The weekly grocery list: every ingredient called for by that week's
/// home-cooked dinners, consolidated and checkable, stepping forward/backward
/// by week just like [MealScheduleController]'s planner.
class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({
    super.key,
    required this.scheduleController,
    required this.mealListController,
    required this.shoppingListController,
  });

  final MealScheduleController scheduleController;
  final MealListController mealListController;
  final ShoppingListController shoppingListController;

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    widget.scheduleController.addListener(_onChanged);
    widget.mealListController.addListener(_onChanged);
    widget.shoppingListController.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.scheduleController.removeListener(_onChanged);
    widget.mealListController.removeListener(_onChanged);
    widget.shoppingListController.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _stepWeek(int direction) => setState(() => _focusedDay = _focusedDay.add(Duration(days: 7 * direction)));

  Future<void> _openWeekPicker() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) => WeekPickerSheet(initialWeekStart: CalendarMath.startOfWeek(_focusedDay)),
    );
    if (picked != null) setState(() => _focusedDay = picked);
  }

  bool get _isCurrentWeek => CalendarMath.isSameDay(CalendarMath.startOfWeek(_focusedDay), CalendarMath.startOfWeek(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    final items = ShoppingListMath.forWeek(
      weekAnchor: _focusedDay,
      scheduleController: widget.scheduleController,
      mealListController: widget.mealListController,
    );
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(
              eyebrow: tr(context, 'shopping.eyebrow'),
              title: tr(context, 'shopping.title'),
              trailing: CountBadge(count: items.length),
            ),
            const SizedBox(height: 8),
            Text(tr(context, 'shopping.subtitle'), style: TextStyle(color: colors.muted)),
            const SizedBox(height: 24),
            SchedulePeriodHeader(
              label: tr(context, 'mealPlan.weekLabel', {'number': '${CalendarMath.isoWeekNumber(_focusedDay)}'}),
              onPrevious: () => _stepWeek(-1),
              onNext: () => _stepWeek(1),
              onTapLabel: _openWeekPicker,
            ),
            if (!_isCurrentWeek)
              Center(
                child: TextButton(
                  key: const Key('jump-to-current-week'),
                  onPressed: () => setState(() => _focusedDay = DateTime.now()),
                  child: Text(tr(context, 'mealPlan.thisWeek')),
                ),
              ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(tr(context, 'shopping.empty'), textAlign: TextAlign.center, style: TextStyle(color: colors.muted)),
                ),
              )
            else
              for (final item in items) ...[
                _ShoppingListRow(
                  item: item,
                  checked: widget.shoppingListController.isChecked(_focusedDay, item.key),
                  onChanged: () => widget.shoppingListController.toggle(_focusedDay, item.key),
                ),
                Divider(height: 1, color: colors.line),
              ],
          ],
        ),
      ),
    );
  }
}

class _ShoppingListRow extends StatelessWidget {
  const _ShoppingListRow({required this.item, required this.checked, required this.onChanged});

  final ShoppingListItem item;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // De-dupe so a meal scheduled twice this week doesn't repeat itself in the caption.
    final mealSummary = item.mealNames.toSet().join(', ');
    return CheckboxListTile(
      key: Key('shopping-item-${item.key}'),
      value: checked,
      onChanged: (_) => onChanged(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(
        item.count > 1 ? '${item.name} \u00d7${item.count}' : item.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: checked ? TextDecoration.lineThrough : null,
          color: checked ? colors.muted : colors.ink,
        ),
      ),
      subtitle: Text(tr(context, 'shopping.forMeals', {'meals': mealSummary}), style: TextStyle(color: colors.muted, fontSize: 12)),
    );
  }
}
