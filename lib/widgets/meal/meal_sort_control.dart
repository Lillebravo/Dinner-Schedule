import 'package:flutter/material.dart';

import '../../controllers/meal_list_controller.dart';
import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';

/// A single icon button that opens a sheet of sort criteria. Tapping a criterion
/// cycles it through ascending → descending → no sort (custom order).
class MealSortControl extends StatelessWidget {
  const MealSortControl({super.key, required this.controller});

  final MealListController controller;

  static const _labelKeys = {
    MealSortCriterion.name: 'sort.name',
    MealSortCriterion.cookTime: 'sort.cookTime',
    MealSortCriterion.favorites: 'sort.favoritesFirst',
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
                  child: Text(tr(context, 'sort.title'), style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.of(context).ink, fontSize: 13)),
                ),
              ),
              for (final criterion in MealSortCriterion.values)
                ListTile(
                  key: Key('sort-option-${criterion.name}'),
                  title: Text(tr(context, _labelKeys[criterion]!)),
                  trailing: controller.activeSortCriterion == criterion
                      ? Icon(controller.isSortDescending ? Icons.arrow_downward : Icons.arrow_upward, color: AppColors.of(context).coral)
                      : Icon(Icons.unfold_more, color: AppColors.of(context).muted),
                  selected: controller.activeSortCriterion == criterion,
                  onTap: () => controller.cycleSort(criterion),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.activeSortCriterion != null;
    return IconButton(
      key: const Key('sort-menu-button'),
      tooltip: tr(context, 'sort.tooltip'),
      onPressed: () => _openSheet(context),
      icon: Badge(isLabelVisible: active, smallSize: 8, child: const Icon(Icons.sort)),
    );
  }
}
