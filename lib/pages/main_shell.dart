import 'package:flutter/material.dart';

import '../controllers/food_list_controller.dart';
import '../controllers/meal_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../controllers/shopping_list_controller.dart';
import '../controllers/theme_mode_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/navigation/app_bottom_nav_bar.dart';
import 'eating_out_wheel_page.dart';
import 'home_meals_list_page.dart';
import 'home_wheel_page.dart';
import 'meal_plan_page.dart';
import 'shopping_list_page.dart';

/// The app's persistent shell: header, bottom navigation, and the five sections.
/// Every section stays mounted via [IndexedStack] so switching tabs never loses
/// in-progress edits or an in-flight wheel spin.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.themeModeController});

  final ThemeModeController themeModeController;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _mealListController = MealListController(const ['Spaghetti Bolognese', 'Chicken Stir-fry', 'Veggie Curry', 'Tacos al Pastor']);
  final _eatingOutController = FoodListController(const [
    'Sushi', 'Burgers', 'Pizza', 'Tacos', 'Ramen', 'Thai',
    'Italian', 'Chinese', 'Indian', 'Korean', 'Kebab', 'Steakhouse', 'Salad', 'Sandwich',
  ]);
  final _scheduleController = MealScheduleController();
  final _shoppingListController = ShoppingListController();

  // Home-cooking wheel sits in the middle of the bottom bar.
  int _selectedIndex = 2;

  @override
  void dispose() {
    _mealListController.dispose();
    _eatingOutController.dispose();
    _scheduleController.dispose();
    _shoppingListController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
        EatingOutWheelPage(controller: _eatingOutController, scheduleController: _scheduleController),
        HomeMealsListPage(controller: _mealListController, scheduleController: _scheduleController),
        HomeWheelPage(controller: _mealListController, scheduleController: _scheduleController),
        ShoppingListPage(
          scheduleController: _scheduleController,
          mealListController: _mealListController,
          shoppingListController: _shoppingListController,
        ),
        MealPlanPage(
          scheduleController: _scheduleController,
          mealListController: _mealListController,
          foodListController: _eatingOutController,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
              child: AppHeader(themeModeController: widget.themeModeController),
            ),
            Expanded(child: IndexedStack(index: _selectedIndex, children: _pages)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedIndex,
        onSelect: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
