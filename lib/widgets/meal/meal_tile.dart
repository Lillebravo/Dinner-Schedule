import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../theme/app_theme.dart';

/// A single meal row: favorite toggle, name, cook time, cooking-mode action,
/// schedule action, and remove action. Tapping the row (outside the icon
/// buttons) opens the meal's recipe details for editing.
class MealTile extends StatelessWidget {
  const MealTile({
    super.key,
    required this.meal,
    required this.canRemove,
    required this.onToggleFavorite,
    required this.onRemove,
    required this.onTap,
    this.scheduleAction,
    this.onStartCooking,
  });

  final Meal meal;
  final bool canRemove;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  /// Shown between the meal's details and the remove button, letting the user
  /// add this meal straight to the schedule.
  final Widget? scheduleAction;

  /// Opens the distraction-free step-by-step cooking view. Disabled (greyed
  /// out, un-tappable) whenever the meal has no instructions yet.
  final VoidCallback? onStartCooking;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.line))),
        child: Row(
          children: [
            IconButton(
              key: Key('favorite-${meal.name}'),
              icon: Icon(meal.isFavorite ? Icons.star : Icons.star_border),
              color: meal.isFavorite ? colors.coral : colors.muted,
              tooltip: meal.isFavorite ? 'Unfavorite ${meal.name}' : 'Favorite ${meal.name}',
              onPressed: onToggleFavorite,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (meal.cookTimeMinutes != null)
                    Text('${meal.cookTimeMinutes} min · ${meal.ingredients.length} ingredients',
                        style: TextStyle(color: colors.muted, fontSize: 12))
                  else
                    Text('${meal.ingredients.length} ingredients', style: TextStyle(color: colors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (onStartCooking != null)
              IconButton(
                key: Key('cooking-mode-${meal.name}'),
                icon: const Icon(Icons.menu_book_outlined),
                color: meal.instructions.trim().isEmpty ? colors.muted.withValues(alpha: 0.4) : colors.muted,
                tooltip: meal.instructions.trim().isEmpty ? 'Add instructions to start cooking mode' : 'Start cooking ${meal.name}',
                onPressed: meal.instructions.trim().isEmpty ? null : onStartCooking,
              ),
            ?scheduleAction,
            IconButton(
              icon: const Icon(Icons.close),
              color: colors.muted,
              tooltip: 'Remove ${meal.name}',
              onPressed: canRemove ? onRemove : null,
            ),
          ],
        ),
      ),
    );
  }
}
