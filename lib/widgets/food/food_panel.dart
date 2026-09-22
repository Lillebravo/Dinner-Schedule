import 'package:flutter/material.dart';

import '../../models/food.dart';
import '../../theme/app_theme.dart';
import '../common/count_badge.dart';
import '../common/entry_input_row.dart';
import '../common/panel_header.dart';
import 'food_list_tile.dart';

/// The wheel-entry management panel: entry form, current entries, and validation feedback.
class FoodPanel extends StatelessWidget {
  const FoodPanel({
    super.key,
    required this.foods,
    required this.inputController,
    required this.onAdd,
    required this.onRemove,
    required this.canRemove,
    this.error,
    this.eyebrow = 'PLACES TO EAT',
    this.title = 'Where should we eat?',
    this.inputHint = 'Try Sushi Palace',
  });

  final List<Food> foods;
  final TextEditingController inputController;
  final VoidCallback onAdd;
  final ValueChanged<Food> onRemove;
  final bool canRemove;
  final String? error;
  final String eyebrow;
  final String title;
  final String inputHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelHeader(eyebrow: eyebrow, title: title, trailing: CountBadge(count: foods.length)),
        const SizedBox(height: 24),
        EntryInputRow(controller: inputController, onSubmit: onAdd, hintText: inputHint),
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
