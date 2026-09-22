import 'package:flutter/material.dart';

import '../../controllers/meal_list_controller.dart';

/// Choice chips for picking how the home meals list is ordered.
class MealSortControl extends StatelessWidget {
  const MealSortControl({super.key, required this.selected, required this.onChanged});

  final MealSortOption selected;
  final ValueChanged<MealSortOption> onChanged;

  static const _labels = {
    MealSortOption.custom: 'Custom order',
    MealSortOption.nameAZ: 'A → Z',
    MealSortOption.nameZA: 'Z → A',
    MealSortOption.cookTimeAsc: 'Time to cook',
    MealSortOption.favoritesFirst: 'Favorites first',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in MealSortOption.values)
          ChoiceChip(
            key: Key('sort-${option.name}'),
            label: Text(_labels[option]!),
            selected: selected == option,
            onSelected: (_) => onChanged(option),
          ),
      ],
    );
  }
}
