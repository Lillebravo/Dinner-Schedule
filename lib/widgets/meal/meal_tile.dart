import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../theme/app_theme.dart';

/// A single meal row: favorite toggle, name, cook time, and remove action. Tapping
/// the row (outside the icon buttons) opens the meal's recipe details for editing.
class MealTile extends StatelessWidget {
  const MealTile({
    super.key,
    required this.meal,
    required this.canRemove,
    required this.onToggleFavorite,
    required this.onRemove,
    required this.onTap,
  });

  final Meal meal;
  final bool canRemove;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        child: Row(
          children: [
            IconButton(
              key: Key('favorite-${meal.name}'),
              icon: Icon(meal.isFavorite ? Icons.star : Icons.star_border),
              color: meal.isFavorite ? AppColors.coral : AppColors.muted,
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
                        style: const TextStyle(color: AppColors.muted, fontSize: 12))
                  else
                    Text('${meal.ingredients.length} ingredients', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: AppColors.muted,
              tooltip: 'Remove ${meal.name}',
              onPressed: canRemove ? onRemove : null,
            ),
          ],
        ),
      ),
    );
  }
}
