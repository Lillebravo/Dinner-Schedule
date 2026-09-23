import 'package:flutter/material.dart';

import '../controllers/meal_list_controller.dart';
import '../models/meal.dart';
import '../theme/app_theme.dart';
import '../widgets/common/count_badge.dart';
import '../widgets/common/entry_input_row.dart';
import '../widgets/common/panel_header.dart';
import '../widgets/meal/meal_edit_sheet.dart';
import '../widgets/meal/meal_filter_control.dart';
import '../widgets/meal/meal_sort_control.dart';
import '../widgets/meal/meal_tile.dart';

/// Manages the user's home-cooked meals: adding, favoriting, sorting, manual
/// ranking, and recipe details (ingredients + instructions).
class HomeMealsListPage extends StatefulWidget {
  const HomeMealsListPage({super.key, required this.controller});

  final MealListController controller;

  @override
  State<HomeMealsListPage> createState() => _HomeMealsListPageState();
}

class _HomeMealsListPageState extends State<HomeMealsListPage> {
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _inputController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _addMeal() {
    if (widget.controller.add(_inputController.text)) {
      _inputController.clear();
    }
  }

  Future<void> _editMeal(Meal meal) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MealEditSheet(
        meal: meal,
        onSave: ({required ingredients, required instructions, cookTimeMinutes, required tags}) {
          widget.controller.updateMeal(
            meal,
            ingredients: ingredients,
            instructions: instructions,
            cookTimeMinutes: cookTimeMinutes,
            tags: tags,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = widget.controller.meals;
    final canRemove = !widget.controller.isAtMinimum;
    final reorderable = widget.controller.sortOption == MealSortOption.custom && widget.controller.activeFilters.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelHeader(eyebrow: 'HOME COOKING', title: 'Your meals', trailing: CountBadge(count: meals.length)),
            const SizedBox(height: 24),
            EntryInputRow(controller: _inputController, onSubmit: _addMeal, hintText: 'Add a home-cooked meal'),
            if (widget.controller.error != null) ...[
              const SizedBox(height: 6),
              Text(widget.controller.error!, key: const Key('field-error'), style: const TextStyle(color: AppColors.errorText, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                MealSortControl(controller: widget.controller),
                MealFilterControl(controller: widget.controller),
              ],
            ),
            const SizedBox(height: 4),
            if (meals.isEmpty)
              const Text('No meals match your filters.', key: Key('no-meals-match'), style: TextStyle(color: AppColors.muted))
            else if (reorderable)
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: widget.controller.reorderCustom,
                children: [
                  for (final meal in meals)
                    MealTile(
                      key: ValueKey('meal-item-${meal.name}'),
                      meal: meal,
                      canRemove: canRemove,
                      onToggleFavorite: () => widget.controller.toggleFavorite(meal),
                      onRemove: () => widget.controller.remove(meal),
                      onTap: () => _editMeal(meal),
                    ),
                ],
              )
            else
              for (final meal in meals)
                MealTile(
                  key: ValueKey('meal-item-${meal.name}'),
                  meal: meal,
                  canRemove: canRemove,
                  onToggleFavorite: () => widget.controller.toggleFavorite(meal),
                  onRemove: () => widget.controller.remove(meal),
                  onTap: () => _editMeal(meal),
                ),
            const SizedBox(height: 12),
            const Text(
              'Keep at least two meals on the list. Drag to reorder while sorted by "Custom order". Tap a meal to add ingredients and instructions.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
