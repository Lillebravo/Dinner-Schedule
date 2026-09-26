import 'package:flutter/material.dart';

import '../../controllers/meal_list_controller.dart';
import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';

/// A single icon button that opens a sheet of smart filters (Quick, Vegetarian,
/// Vegan, Pescatarian, Gluten-Free, Comfort Food, Pantry Friendly).
class MealFilterControl extends StatelessWidget {
  const MealFilterControl({super.key, required this.controller});

  final MealListController controller;

  static const _labelKeys = {
    MealFilter.quick: 'filter.quick',
    MealFilter.vegetarian: 'filter.vegetarian',
    MealFilter.vegan: 'filter.vegan',
    MealFilter.pescatarian: 'filter.pescatarian',
    MealFilter.glutenFree: 'filter.glutenFree',
    MealFilter.comfortFood: 'filter.comfortFood',
    MealFilter.pantryFriendly: 'filter.pantryFriendly',
  };

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(tr(context, 'filter.title'), style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.of(context).ink, fontSize: 13)),
                ),
              ),
              for (final filter in MealFilter.values)
                CheckboxListTile(
                  key: Key('filter-${filter.name}'),
                  title: Text(tr(context, _labelKeys[filter]!)),
                  value: controller.activeFilters.contains(filter),
                  onChanged: (_) => controller.toggleFilter(filter),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.activeFilters.isNotEmpty;
    return IconButton(
      key: const Key('filter-menu-button'),
      tooltip: tr(context, 'filter.tooltip'),
      onPressed: () => _openSheet(context),
      icon: Badge(
        isLabelVisible: active,
        label: Text('${controller.activeFilters.length}'),
        child: const Icon(Icons.filter_alt_outlined),
      ),
    );
  }
}
