import 'package:flutter/material.dart';

import '../../controllers/meal_list_controller.dart';
import '../../l10n/app_locale.dart';
import '../../models/scheduled_dinner.dart';
import '../../pages/cooking_mode_page.dart';
import '../../theme/app_theme.dart';
import 'servings_editor_sheet.dart';

/// A drag payload carrying which day a dinner is being dragged from, so the
/// day it's dropped on knows what to swap with.
class DinnerDragData {
  const DinnerDragData(this.day, this.dinner);
  final DateTime day;
  final ScheduledDinner dinner;
}

const _weekdayAbbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// One day's row in the weekly schedule: date, weekday, and its dinner slot.
/// Doubles as a [LongPressDraggable] source (when it has a dinner) and a
/// [DragTarget] (always), so dinners can be dragged between days to rearrange
/// the week. A home-cooked dinner also shows its planned serving count
/// (editable) and, when that recipe has instructions, a button straight into
/// cooking mode.
class DayDinnerCard extends StatelessWidget {
  const DayDinnerCard({
    super.key,
    required this.day,
    required this.dinner,
    required this.isToday,
    required this.mealListController,
    required this.onAddMeal,
    required this.onAddEatingOut,
    required this.onClear,
    required this.onChangeServings,
    required this.onDropDinner,
  });

  final DateTime day;
  final ScheduledDinner? dinner;
  final bool isToday;
  final MealListController mealListController;
  final VoidCallback onAddMeal;
  final VoidCallback onAddEatingOut;
  final VoidCallback onClear;
  final ValueChanged<int> onChangeServings;
  final ValueChanged<DinnerDragData> onDropDinner;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DragTarget<DinnerDragData>(
      onWillAcceptWithDetails: (details) => details.data.day != day,
      onAcceptWithDetails: (details) => onDropDinner(details.data),
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        return Container(
          key: Key('day-card-${day.toIso8601String()}'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: isToday ? colors.coral : colors.line, width: isToday ? 2 : 1),
            color: highlighted ? colors.coral.withValues(alpha: 0.08) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_weekdayAbbreviations[day.weekday - 1], style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink)),
                    Text('${day.day}', style: TextStyle(color: colors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildSlot(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlot(BuildContext context) {
    final scheduled = dinner;
    if (scheduled == null) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            key: Key('add-meal-${day.toIso8601String()}'),
            onPressed: onAddMeal,
            icon: const Icon(Icons.restaurant_menu, size: 18),
            label: Text(tr(context, 'schedule.addMealButton')),
          ),
          OutlinedButton.icon(
            key: Key('add-eating-out-${day.toIso8601String()}'),
            onPressed: onAddEatingOut,
            icon: const Icon(Icons.restaurant_outlined, size: 18),
            label: Text(tr(context, 'schedule.eatOutButton')),
          ),
        ],
      );
    }

    final colors = AppColors.of(context);
    final cookableMeal = scheduled.type == DinnerType.homeCooked ? mealListController.findByName(scheduled.title) : null;
    final canStartCooking = cookableMeal != null && cookableMeal.instructions.trim().isNotEmpty;

    return LongPressDraggable<DinnerDragData>(
      data: DinnerDragData(day, scheduled),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 220, child: _DinnerChip(dinner: scheduled)),
      ),
      childWhenDragging: _DinnerChip(dinner: scheduled, faded: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _DinnerChip(dinner: scheduled)),
              if (scheduled.type == DinnerType.homeCooked)
                IconButton(
                  key: Key('day-card-cooking-mode-${day.toIso8601String()}'),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  tooltip: tr(context, 'mealPlan.startCookingTooltip'),
                  color: colors.muted,
                  onPressed: canStartCooking
                      ? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => CookingModePage(meal: cookableMeal)))
                      : null,
                ),
              IconButton(
                key: Key('clear-dinner-${day.toIso8601String()}'),
                icon: const Icon(Icons.close, size: 18),
                color: colors.muted,
                tooltip: tr(context, 'schedule.clearDinner'),
                onPressed: onClear,
              ),
            ],
          ),
          if (scheduled.type == DinnerType.homeCooked) ...[
            const SizedBox(height: 4),
            InkWell(
              key: Key('day-card-servings-${day.toIso8601String()}'),
              onTap: () => showServingsEditorSheet(context, current: scheduled.servings, onSave: onChangeServings),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tr(context, 'mealPlan.servingsLabel', {'count': '${scheduled.servings}'}), style: TextStyle(color: colors.muted, fontSize: 12)),
                    const SizedBox(width: 4),
                    Icon(Icons.edit_outlined, size: 12, color: colors.muted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DinnerChip extends StatelessWidget {
  const _DinnerChip({required this.dinner, this.faded = false});

  final ScheduledDinner dinner;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Opacity(
      opacity: faded ? 0.3 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: colors.surface, border: Border.all(color: colors.line)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(dinner.type == DinnerType.homeCooked ? Icons.soup_kitchen_outlined : Icons.restaurant_outlined,
                size: 16, color: colors.coralDark),
            const SizedBox(width: 8),
            Flexible(child: Text(dinner.title, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
