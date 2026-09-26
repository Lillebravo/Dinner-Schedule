import 'package:flutter/material.dart';

import '../../models/scheduled_dinner.dart';
import '../../theme/app_theme.dart';
import 'day_dinner_card.dart';

/// A single day cell in the monthly grid: date number, a small dinner indicator
/// if one is scheduled, and a drop target for drag-and-drop rearranging. Tapping
/// the cell opens the day's full detail sheet.
class MonthDayCell extends StatelessWidget {
  const MonthDayCell({
    super.key,
    required this.day,
    required this.dinner,
    required this.inCurrentMonth,
    required this.isToday,
    required this.onTap,
    required this.onDropDinner,
  });

  final DateTime day;
  final ScheduledDinner? dinner;
  final bool inCurrentMonth;
  final bool isToday;
  final VoidCallback onTap;
  final ValueChanged<DinnerDragData> onDropDinner;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DragTarget<DinnerDragData>(
      onWillAcceptWithDetails: (details) => details.data.day != day,
      onAcceptWithDetails: (details) => onDropDinner(details.data),
      builder: (context, candidateData, rejectedData) {
        final scheduled = dinner;
        final highlighted = candidateData.isNotEmpty;
        // Cap text scaling so a day's number and dinner label can't outgrow the
        // grid cell's fixed height under large accessibility text sizes.
        final cappedScaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);
        final content = MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: cappedScaler),
          child: Container(
            key: Key('month-cell-${day.toIso8601String()}'),
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: isToday ? colors.coral : colors.line, width: isToday ? 2 : 0.5),
              color: highlighted ? colors.coral.withValues(alpha: 0.08) : Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(fontWeight: FontWeight.w800, color: inCurrentMonth ? colors.ink : colors.line),
                ),
                if (scheduled != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: colors.background, border: Border.all(color: colors.line)),
                    child: Text(
                      scheduled.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        final tappable = InkWell(onTap: onTap, child: content);
        if (scheduled == null) return tappable;

        return LongPressDraggable<DinnerDragData>(
          data: DinnerDragData(day, scheduled),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: colors.surface, border: Border.all(color: colors.line)),
              child: Text(scheduled.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: tappable),
          child: tappable,
        );
      },
    );
  }
}
