import 'package:flutter/material.dart';

import '../../controllers/food_list_controller.dart';
import '../../controllers/meal_list_controller.dart';
import '../../models/scheduled_dinner.dart';
import '../../theme/app_theme.dart';

/// A bottom sheet for picking what a day's dinner will be: a meal from the home
/// meals list, or a place from the eating-out list. Pops with the chosen
/// [ScheduledDinner], or null if dismissed.
class DinnerPickerSheet extends StatelessWidget {
  const DinnerPickerSheet({
    super.key,
    required this.mealListController,
    required this.foodListController,
    this.initialTab = DinnerType.homeCooked,
  });

  final MealListController mealListController;
  final FoodListController foodListController;
  final DinnerType initialTab;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab == DinnerType.homeCooked ? 0 : 1,
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Pick tonight's dinner", style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink, fontSize: 16)),
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(key: Key('dinner-picker-tab-meals'), text: 'Home-cooked'),
                  Tab(key: Key('dinner-picker-tab-eating-out'), text: 'Eating out'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _EntryList(
                      names: [for (final meal in mealListController.meals) meal.name],
                      emptyMessage: 'Add meals in the Meals tab first.',
                      onPick: (name) => Navigator.of(context).pop(ScheduledDinner(title: name, type: DinnerType.homeCooked)),
                    ),
                    _EntryList(
                      names: [for (final food in foodListController.foods) food.name],
                      emptyMessage: 'Add places in the Eat Out tab first.',
                      onPick: (name) => Navigator.of(context).pop(ScheduledDinner(title: name, type: DinnerType.eatingOut)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.names, required this.emptyMessage, required this.onPick});

  final List<String> names;
  final String emptyMessage;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(color: AppColors.muted)));
    }
    return ListView(
      children: [
        for (final name in names)
          ListTile(
            key: Key('dinner-picker-option-$name'),
            title: Text(name),
            onTap: () => onPick(name),
          ),
      ],
    );
  }
}
