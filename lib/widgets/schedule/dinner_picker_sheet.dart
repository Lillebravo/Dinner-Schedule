import 'package:flutter/material.dart';

import '../../controllers/food_list_controller.dart';
import '../../controllers/meal_list_controller.dart';
import '../../l10n/app_locale.dart';
import '../../models/meal.dart';
import '../../models/scheduled_dinner.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../common/servings_stepper.dart';

/// A bottom sheet for picking what a day's dinner will be: a meal from the home
/// meals list, or a place from the eating-out list. Picking a home-cooked meal
/// shows a servings confirmation step (defaulting to that recipe's own serving
/// size) before adding it, since that's what the shopping list later scales
/// its ingredients by. Pops with the chosen [ScheduledDinner], or null if
/// dismissed.
class DinnerPickerSheet extends StatefulWidget {
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
  State<DinnerPickerSheet> createState() => _DinnerPickerSheetState();
}

class _DinnerPickerSheetState extends State<DinnerPickerSheet> {
  String? _selectedMealName;
  int _servings = Meal.defaultServings;

  void _selectMeal(String name) {
    final meal = widget.mealListController.findByName(name);
    setState(() {
      _selectedMealName = name;
      _servings = meal?.servings ?? Meal.defaultServings;
    });
  }

  void _confirmMeal() {
    Navigator.of(context).pop(ScheduledDinner(title: _selectedMealName!, type: DinnerType.homeCooked, servings: _servings));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab == DinnerType.homeCooked ? 0 : 1,
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Pick tonight's dinner", style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.of(context).ink, fontSize: 16)),
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
                    _selectedMealName == null
                        ? _EntryList(
                            names: [for (final meal in widget.mealListController.meals) meal.name],
                            emptyMessage: 'Add meals in the Meals tab first.',
                            onPick: _selectMeal,
                          )
                        : _ServingsConfirm(
                            mealName: _selectedMealName!,
                            servings: _servings,
                            onChangeServings: (value) => setState(() => _servings = value),
                            onBack: () => setState(() => _selectedMealName = null),
                            onConfirm: _confirmMeal,
                          ),
                    _EntryList(
                      names: [for (final food in widget.foodListController.foods) food.name],
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

/// Shown after picking a home-cooked meal: lets the user confirm (or adjust)
/// how many servings they're planning to cook that day before adding it.
class _ServingsConfirm extends StatelessWidget {
  const _ServingsConfirm({
    required this.mealName,
    required this.servings,
    required this.onChangeServings,
    required this.onBack,
    required this.onConfirm,
  });

  final String mealName;
  final int servings;
  final ValueChanged<int> onChangeServings;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(key: const Key('dinner-picker-back'), icon: const Icon(Icons.arrow_back), onPressed: onBack),
              Expanded(
                child: Text(mealName, style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink, fontSize: 16), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ServingsStepper(servings: servings, onChanged: onChangeServings),
          const SizedBox(height: 24),
          PrimaryButton(key: const Key('dinner-picker-confirm'), label: tr(context, 'common.add'), onPressed: onConfirm),
        ],
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
      return Center(child: Text(emptyMessage, style: TextStyle(color: AppColors.of(context).muted)));
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
