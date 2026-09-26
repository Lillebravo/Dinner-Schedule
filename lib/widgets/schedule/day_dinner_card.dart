import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/scheduled_dinner.dart';
import '../../theme/app_theme.dart';

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
/// the week.
class DayDinnerCard extends StatelessWidget {
  const DayDinnerCard({
    super.key,
    required this.day,
    required this.dinner,
    required this.isToday,
    required this.onAddMeal,
    required this.onAddEatingOut,
    required this.onClear,
    required this.onDropDinner,
  });

  final DateTime day;
  final ScheduledDinner? dinner;
  final bool isToday;
  final VoidCallback onAddMeal;
  final VoidCallback onAddEatingOut;
  final VoidCallback onClear;
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

    return LongPressDraggable<DinnerDragData>(
      data: DinnerDragData(day, scheduled),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 220, child: _DinnerChip(dinner: scheduled)),
      ),
      childWhenDragging: _DinnerChip(dinner: scheduled, faded: true),
      child: Row(
        children: [
          Expanded(child: _DinnerChip(dinner: scheduled)),
          IconButton(
            key: Key('clear-dinner-${day.toIso8601String()}'),
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.of(context).muted,
            tooltip: tr(context, 'schedule.clearDinner'),
            onPressed: onClear,
          ),
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
