import 'package:flutter/material.dart';

import '../../controllers/meal_list_controller.dart';

/// Multi-select chips constraining the meals list and wheel by tag, per the
/// app's "smart filters" (Quick, Vegetarian, Comfort Food, Pantry Friendly).
class MealFilterControl extends StatelessWidget {
  const MealFilterControl({super.key, required this.active, required this.onToggle});

  final Set<MealFilter> active;
  final ValueChanged<MealFilter> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final filter in MealFilter.values)
          FilterChip(
            key: Key('filter-${filter.name}'),
            label: Text(filter.label),
            selected: active.contains(filter),
            onSelected: (_) => onToggle(filter),
          ),
      ],
    );
  }
}
