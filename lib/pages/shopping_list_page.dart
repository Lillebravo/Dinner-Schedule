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
import '../widgets/common/entry_input_row.dart';
import '../widgets/common/panel_header.dart';
import '../widgets/schedule/schedule_period_header.dart';
import '../widgets/schedule/week_picker_sheet.dart';
import '../widgets/shopping/shopping_sort_control.dart';

/// The weekly grocery list: every ingredient called for by that week's
/// home-cooked dinners, plus any hand-added extras, consolidated and
/// checkable, sortable/filterable, and stepping forward/backward by week just
/// like [MealScheduleController]'s planner.
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
  final _manualItemController = TextEditingController();
  final _sortController = ShoppingSortController();
  late DateTime _focusedDay;
  bool _hideBought = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    widget.scheduleController.addListener(_onChanged);
    widget.mealListController.addListener(_onChanged);
    widget.shoppingListController.addListener(_onChanged);
    _sortController.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.scheduleController.removeListener(_onChanged);
    widget.mealListController.removeListener(_onChanged);
    widget.shoppingListController.removeListener(_onChanged);
    _sortController.removeListener(_onChanged);
    _manualItemController.dispose();
    _sortController.dispose();
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

  void _addManualItem() {
    widget.shoppingListController.addManualItem(_focusedDay, _manualItemController.text);
    _manualItemController.clear();
  }

  int _compareItems(ShoppingListItem a, ShoppingListItem b) {
    switch (_sortController.option) {
      case ShoppingSortOption.nameAZ:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case ShoppingSortOption.nameZA:
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      case ShoppingSortOption.uncheckedFirst:
        final aChecked = widget.shoppingListController.isChecked(_focusedDay, a.key);
        final bChecked = widget.shoppingListController.isChecked(_focusedDay, b.key);
        if (aChecked != bChecked) return aChecked ? 1 : -1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case ShoppingSortOption.custom:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final autoItems = ShoppingListMath.forWeek(
      weekAnchor: _focusedDay,
      scheduleController: widget.scheduleController,
      mealListController: widget.mealListController,
    ).where((item) => !widget.shoppingListController.isAutoItemHidden(_focusedDay, item.key));
    final manualItems = widget.shoppingListController.manualItemsForWeek(_focusedDay);
    final allItems = [...autoItems, ...manualItems];

    final checkedCount = allItems.where((item) => widget.shoppingListController.isChecked(_focusedDay, item.key)).length;

    final displayItems = (_hideBought ? allItems.where((item) => !widget.shoppingListController.isChecked(_focusedDay, item.key)) : allItems).toList();
    // Dart's List.sort isn't stable, so only resort when a criterion is actually active - otherwise leave the natural merge order untouched.
    if (_sortController.option != ShoppingSortOption.custom) displayItems.sort(_compareItems);

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
              trailing: CountBadge(count: allItems.length),
            ),
            const SizedBox(height: 8),
            Text(tr(context, 'shopping.subtitle'), style: TextStyle(color: colors.muted)),
            const SizedBox(height: 20),
            EntryInputRow(controller: _manualItemController, onSubmit: _addManualItem, hintText: tr(context, 'shopping.addItemHint')),
            const SizedBox(height: 20),
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
            const SizedBox(height: 16),
            Row(
              children: [
                ShoppingSortControl(controller: _sortController),
                const SizedBox(width: 4),
                FilterChip(
                  key: const Key('hide-bought-filter'),
                  label: Text(tr(context, 'shopping.hideBought')),
                  selected: _hideBought,
                  onSelected: (value) => setState(() => _hideBought = value),
                ),
                const Spacer(),
                TextButton.icon(
                  key: const Key('finish-shopping-button'),
                  onPressed: checkedCount > 0 ? () => widget.shoppingListController.finishShopping(_focusedDay, allItems) : null,
                  icon: const Icon(Icons.done_all),
                  label: Text(tr(context, 'shopping.doneShopping')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (allItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(tr(context, 'shopping.empty'), textAlign: TextAlign.center, style: TextStyle(color: colors.muted)),
                ),
              )
            else if (displayItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(tr(context, 'shopping.allBought'), textAlign: TextAlign.center, style: TextStyle(color: colors.muted)),
                ),
              )
            else
              for (final item in displayItems) ...[
                _ShoppingListRow(
                  item: item,
                  checked: widget.shoppingListController.isChecked(_focusedDay, item.key),
                  onChanged: () => widget.shoppingListController.toggle(_focusedDay, item.key),
                  onDelete: item.isManual ? () => widget.shoppingListController.removeManualItem(_focusedDay, item.manualId!) : null,
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
  const _ShoppingListRow({required this.item, required this.checked, required this.onChanged, this.onDelete});

  final ShoppingListItem item;
  final bool checked;
  final VoidCallback onChanged;
  final VoidCallback? onDelete;

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
      subtitle: Text(
        item.isManual ? tr(context, 'shopping.addedManually') : tr(context, 'shopping.forMeals', {'meals': mealSummary}),
        style: TextStyle(color: colors.muted, fontSize: 12),
      ),
      secondary: onDelete == null
          ? null
          : IconButton(
              key: Key('shopping-item-remove-${item.key}'),
              icon: const Icon(Icons.close),
              color: colors.muted,
              tooltip: 'Remove ${item.name}',
              onPressed: onDelete,
            ),
    );
  }
}
