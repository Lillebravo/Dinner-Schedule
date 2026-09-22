import 'package:flutter/material.dart';

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
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.muted,
            tooltip: 'Remove ${food.name}',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
