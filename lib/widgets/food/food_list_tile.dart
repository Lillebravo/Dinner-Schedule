import 'package:flutter/material.dart';

import '../../l10n/food_name_translations.dart';
import '../../models/food.dart';
import '../../theme/app_theme.dart';

/// A single removable entry in the food list.
class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.food, required this.onRemove});

  final Food food;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('food-item-${food.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.of(context).line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(translateFoodName(context, food.name), style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.of(context).muted,
            tooltip: 'Remove ${food.name}',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
