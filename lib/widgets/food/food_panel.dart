import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
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
    this.eyebrow,
    this.title,
    this.inputHint,
  });

  final List<Food> foods;
  final TextEditingController inputController;
  final VoidCallback onAdd;
  final ValueChanged<Food> onRemove;
  final bool canRemove;
  final String? error;
  final String? eyebrow;
  final String? title;
  final String? inputHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelHeader(
          eyebrow: eyebrow ?? tr(context, 'foodPanel.eyebrow'),
          title: title ?? tr(context, 'foodPanel.title'),
          trailing: CountBadge(count: foods.length),
        ),
        const SizedBox(height: 24),
        EntryInputRow(controller: inputController, onSubmit: onAdd, hintText: inputHint ?? tr(context, 'foodPanel.inputHint')),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(error!, key: const Key('field-error'), style: TextStyle(color: AppColors.of(context).errorText, fontSize: 12)),
        ],
        const SizedBox(height: 12),
        for (final food in foods) FoodListTile(food: food, onRemove: canRemove ? () => onRemove(food) : null),
        const SizedBox(height: 12),
        Text(tr(context, 'foodPanel.keepAtLeastTwo'), style: TextStyle(color: AppColors.of(context).muted, fontSize: 12)),
      ],
    );
  }
}
