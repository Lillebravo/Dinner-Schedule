import 'package:flutter/material.dart';

import '../controllers/meal_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../controllers/shopping_list_controller.dart';
import '../l10n/app_locale.dart';
import '../models/shopping_list_item.dart';
import '../theme/app_theme.dart';
import '../utils/aisle_categorizer.dart';
import '../utils/calendar_math.dart';
import '../utils/quantity_format.dart';
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
  bool _groupByAisle = false;

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
            FilterChip(
              key: const Key('group-by-aisle-filter'),
              label: Text(tr(context, 'shopping.groupByAisle')),
              selected: _groupByAisle,
              onSelected: (value) => setState(() => _groupByAisle = value),
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
              ..._buildItemList(displayItems, colors),
          ],
        ),
      ),
    );
  }

  /// Renders the main (non-stashed) items - grouped under aisle headers when
  /// [_groupByAisle] is on, otherwise in the active sort order - followed by a
  /// separate "Already have" section for anything marked as pantry-stashed,
  /// so stocked-up ingredients stop cluttering what's actually left to buy.
  List<Widget> _buildItemList(List<ShoppingListItem> items, AppColors colors) {
    final notStashed = items.where((item) => !widget.shoppingListController.isStashed(item)).toList();
    final stashed = items.where((item) => widget.shoppingListController.isStashed(item)).toList();

    final widgets = <Widget>[
      if (_groupByAisle) ..._buildAisleGroups(notStashed, colors) else ...[for (final item in notStashed) ..._buildRow(item, colors)],
    ];

    if (stashed.isNotEmpty) {
      widgets.add(const SizedBox(height: 16));
      widgets.add(Text(
        tr(context, 'shopping.alreadyHave', {'count': '${stashed.length}'}),
        key: const Key('already-have-header'),
        style: TextStyle(fontWeight: FontWeight.w800, color: colors.muted, fontSize: 12, letterSpacing: 1.0),
      ));
      widgets.add(const SizedBox(height: 4));
      for (final item in stashed) {
        widgets.addAll(_buildRow(item, colors));
      }
    }
    return widgets;
  }

  List<Widget> _buildAisleGroups(List<ShoppingListItem> items, AppColors colors) {
    final grouped = <GroceryAisle, List<ShoppingListItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(widget.shoppingListController.aisleFor(item), () => []).add(item);
    }

    final widgets = <Widget>[];
    for (final aisle in GroceryAisle.values) {
      final aisleItems = grouped[aisle];
      if (aisleItems == null || aisleItems.isEmpty) continue;
      aisleItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          tr(context, 'aisle.${aisle.name}'),
          key: Key('aisle-header-${aisle.name}'),
          style: TextStyle(fontWeight: FontWeight.w800, color: colors.muted, fontSize: 12, letterSpacing: 1.0),
        ),
      ));
      for (final item in aisleItems) {
        widgets.addAll(_buildRow(item, colors));
      }
    }
    return widgets;
  }

  List<Widget> _buildRow(ShoppingListItem item, AppColors colors) {
    return [
      _ShoppingListRow(
        item: item,
        checked: widget.shoppingListController.isChecked(_focusedDay, item.key),
        stashed: widget.shoppingListController.isStashed(item),
        aisle: widget.shoppingListController.aisleFor(item),
        onChanged: () => widget.shoppingListController.toggle(_focusedDay, item.key),
        onToggleStash: () => widget.shoppingListController.toggleStash(item),
        onChangeAisle: (aisle) => widget.shoppingListController.setAisle(item, aisle),
        onDelete: item.isManual ? () => widget.shoppingListController.removeManualItem(_focusedDay, item.manualId!) : null,
      ),
      Divider(height: 1, color: colors.line),
    ];
  }
}

class _ShoppingListRow extends StatelessWidget {
  const _ShoppingListRow({
    required this.item,
    required this.checked,
    required this.stashed,
    required this.aisle,
    required this.onChanged,
    required this.onToggleStash,
    required this.onChangeAisle,
    this.onDelete,
  });

  final ShoppingListItem item;
  final bool checked;
  final bool stashed;
  final GroceryAisle aisle;
  final VoidCallback onChanged;
  final VoidCallback onToggleStash;
  final ValueChanged<GroceryAisle> onChangeAisle;
  final VoidCallback? onDelete;

  /// The exact summed amount (e.g. "5 cups flour" or "50.5g flour") when every
  /// contributing recipe gave a usable quantity, otherwise the old count-based
  /// fallback (e.g. "Onion \u00d72") or just the plain name for a single occurrence.
  String get _title {
    if (item.totalQuantity != null) {
      return '${QuantityFormat.withUnit(item.totalQuantity!, item.unit)} ${item.name}';
    }
    return item.count > 1 ? '${item.name} \u00d7${item.count}' : item.name;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // De-dupe so a meal scheduled twice this week doesn't repeat itself in the caption.
    final mealSummary = item.mealNames.toSet().join(', ');
    final muted = checked || stashed;
    return CheckboxListTile(
      key: Key('shopping-item-${item.key}'),
      value: checked,
      onChanged: (_) => onChanged(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(
        _title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: checked ? TextDecoration.lineThrough : null,
          fontStyle: stashed ? FontStyle.italic : FontStyle.normal,
          color: muted ? colors.muted : colors.ink,
        ),
      ),
      subtitle: Text(
        item.isManual ? tr(context, 'shopping.addedManually') : tr(context, 'shopping.forMeals', {'meals': mealSummary}),
        style: TextStyle(color: colors.muted, fontSize: 12),
      ),
      secondary: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<GroceryAisle>(
            key: Key('shopping-item-aisle-${item.key}'),
            tooltip: tr(context, 'shopping.changeAisle'),
            icon: Icon(Icons.storefront_outlined, color: colors.muted, size: 20),
            onSelected: onChangeAisle,
            itemBuilder: (context) => [
              for (final option in GroceryAisle.values)
                PopupMenuItem(
                  key: Key('aisle-option-${item.key}-${option.name}'),
                  value: option,
                  child: Text(tr(context, 'aisle.${option.name}')),
                ),
            ],
          ),
          IconButton(
            key: Key('shopping-item-stash-${item.key}'),
            icon: Icon(stashed ? Icons.home : Icons.home_outlined),
            color: stashed ? colors.coral : colors.muted,
            tooltip: stashed ? tr(context, 'shopping.unmarkHave') : tr(context, 'shopping.markHave'),
            onPressed: onToggleStash,
          ),
          if (onDelete != null)
            IconButton(
              key: Key('shopping-item-remove-${item.key}'),
              icon: const Icon(Icons.close),
              color: colors.muted,
              tooltip: 'Remove ${item.name}',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
