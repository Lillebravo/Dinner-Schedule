import 'package:flutter/material.dart';

import '../controllers/food_list_controller.dart';
import '../controllers/meal_list_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/navigation/app_bottom_nav_bar.dart';
import 'eating_out_wheel_page.dart';
import 'home_meals_list_page.dart';
import 'home_wheel_page.dart';
import 'placeholder_page.dart';

/// The app's persistent shell: header, bottom navigation, and the five sections.
/// Every section stays mounted via [IndexedStack] so switching tabs never loses
/// in-progress edits or an in-flight wheel spin.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _mealListController = MealListController(const ['Spaghetti Bolognese', 'Chicken Stir-fry', 'Veggie Curry', 'Tacos al Pastor']);
  final _eatingOutController = FoodListController(const ['Sushi Bar', 'Burger Place', 'Pizzeria', 'Taco Truck']);

  // Home-cooking wheel sits in the middle of the bottom bar.
  int _selectedIndex = 2;

  @override
  void dispose() {
    _mealListController.dispose();
    _eatingOutController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
        EatingOutWheelPage(controller: _eatingOutController),
        HomeMealsListPage(controller: _mealListController),
        HomeWheelPage(controller: _mealListController),
        const PlaceholderPage(
          eyebrow: 'COMING SOON',
          title: 'Shopping list',
          subtitle: 'Build a weekly shopping list from your favorite home-cooked meals.',
          icon: Icons.shopping_cart_outlined,
        ),
        const PlaceholderPage(
          eyebrow: 'COMING SOON',
          title: 'Meal planning',
          subtitle: 'Plan out each night of the week ahead of time.',
          icon: Icons.calendar_month_outlined,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.fromLTRB(28, 24, 28, 16), child: AppHeader()),
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
