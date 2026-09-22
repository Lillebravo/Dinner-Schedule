import 'package:flutter/material.dart';

import '../../models/food.dart';
import '../../theme/app_theme.dart';
import '../common/eyebrow_label.dart';
import 'food_count_badge.dart';
import 'food_input_row.dart';
import 'food_list_tile.dart';

/// The right-hand panel: entry form, current entries, and validation feedback.
class FoodPanel extends StatelessWidget {
  const FoodPanel({
    super.key,
    required this.foods,
    required this.inputController,
    required this.onAdd,
    required this.onRemove,
    required this.canRemove,
    this.error,
  });

  final List<Food> foods;
  final TextEditingController inputController;
  final VoidCallback onAdd;
  final ValueChanged<Food> onRemove;
  final bool canRemove;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EyebrowLabel('WHEEL ENTRIES'),
                  SizedBox(height: 6),
                  Text("What's on the table?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FoodCountBadge(count: foods.length),
          ],
        ),
        const SizedBox(height: 24),
        FoodInputRow(controller: inputController, onSubmit: onAdd),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error!, key: const Key('field-error'), style: const TextStyle(color: AppColors.errorText, fontSize: 12)),
        ],
        const SizedBox(height: 12),
        for (final food in foods) FoodListTile(food: food, onRemove: canRemove ? () => onRemove(food) : null),
        const SizedBox(height: 12),
        const Text('Keep at least two choices on the wheel.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}
