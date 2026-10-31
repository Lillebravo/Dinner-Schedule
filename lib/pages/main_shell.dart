import 'package:flutter/material.dart';

import '../controllers/food_list_controller.dart';
import '../controllers/meal_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../controllers/shopping_list_controller.dart';
import '../controllers/theme_mode_controller.dart';
import '../models/ingredient.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/navigation/app_bottom_nav_bar.dart';
import 'eating_out_wheel_page.dart';
import 'home_meals_list_page.dart';
import 'home_wheel_page.dart';
import 'meal_plan_page.dart';
import 'shopping_list_page.dart';

/// Builds the home-cooked meals list pre-filled with ingredients and
/// instructions for its four default recipes, so cooking mode, the shopping
/// list, and serving-size scaling all have something real to try immediately.
MealListController _buildDefaultMealListController() {
  final controller = MealListController(const ['Spaghetti Bolognese', 'Chicken Stir-fry', 'Veggie Curry', 'Tacos al Pastor']);

  controller.updateMeal(
    controller.findByName('Spaghetti Bolognese')!,
    cookTimeMinutes: 40,
    servings: 4,
    tags: const {},
    ingredients: [
      Ingredient(quantity: 500, unit: 'g', name: 'ground beef'),
      Ingredient(quantity: 1, name: 'onion'),
      Ingredient(quantity: 2, unit: 'cloves', name: 'garlic'),
      Ingredient(quantity: 400, unit: 'g', name: 'canned crushed tomatoes'),
      Ingredient(quantity: 2, unit: 'tbsp', name: 'tomato paste'),
      Ingredient(quantity: 400, unit: 'g', name: 'spaghetti'),
      Ingredient(quantity: 2, unit: 'tbsp', name: 'olive oil'),
      Ingredient(name: 'salt and pepper, to taste'),
      Ingredient(name: 'parmesan, to serve'),
    ],
    instructions: 'Finely chop the onion and garlic.\n'
        'Heat the olive oil in a large pan and sauté the onion until soft.\n'
        'Add the garlic and ground beef, breaking it up, and brown it.\n'
        'Stir in the tomato paste, then add the crushed tomatoes.\n'
        'Simmer uncovered for 20 minutes, seasoning with salt and pepper.\n'
        'Meanwhile, cook the spaghetti in salted boiling water until al dente.\n'
        'Drain the pasta and toss with the sauce. Serve topped with parmesan.',
  );

  controller.updateMeal(
    controller.findByName('Chicken Stir-fry')!,
    cookTimeMinutes: 25,
    servings: 4,
    tags: const {},
    ingredients: [
      Ingredient(quantity: 500, unit: 'g', name: 'chicken breast'),
      Ingredient(quantity: 2, name: 'bell peppers'),
      Ingredient(quantity: 200, unit: 'g', name: 'broccoli'),
      Ingredient(quantity: 3, unit: 'tbsp', name: 'soy sauce'),
      Ingredient(quantity: 2, unit: 'cloves', name: 'garlic'),
      Ingredient(quantity: 1, unit: 'tbsp', name: 'ginger'),
      Ingredient(quantity: 2, unit: 'tbsp', name: 'vegetable oil'),
      Ingredient(quantity: 300, unit: 'g', name: 'rice'),
    ],
    instructions: 'Cook the rice according to the package instructions.\n'
        'Slice the chicken breast into thin strips.\n'
        'Chop the bell peppers and broccoli into bite-sized pieces.\n'
        'Heat the vegetable oil in a wok over high heat.\n'
        'Stir-fry the chicken until browned, then set aside.\n'
        'Add the garlic and ginger, then the vegetables, and stir-fry for 3-4 minutes.\n'
        'Return the chicken to the wok, add the soy sauce, and toss everything together.\n'
        'Serve hot over the rice.',
  );

  controller.updateMeal(
    controller.findByName('Veggie Curry')!,
    cookTimeMinutes: 35,
    servings: 4,
    tags: const {},
    ingredients: [
      Ingredient(quantity: 400, unit: 'g', name: 'canned chickpeas'),
      Ingredient(quantity: 400, unit: 'ml', name: 'coconut milk'),
      Ingredient(quantity: 2, unit: 'tbsp', name: 'curry powder'),
      Ingredient(quantity: 1, name: 'onion'),
      Ingredient(quantity: 2, unit: 'cloves', name: 'garlic'),
      Ingredient(quantity: 200, unit: 'g', name: 'spinach'),
      Ingredient(quantity: 300, unit: 'g', name: 'rice'),
      Ingredient(quantity: 1, unit: 'tbsp', name: 'vegetable oil'),
    ],
    instructions: 'Cook the rice according to the package instructions.\n'
        'Finely chop the onion and garlic.\n'
        'Heat the oil in a pot and sauté the onion until translucent.\n'
        'Add the garlic and curry powder and cook for a minute until fragrant.\n'
        'Stir in the coconut milk and drained chickpeas.\n'
        'Simmer for 15 minutes, stirring occasionally.\n'
        'Stir in the spinach and cook until wilted.\n'
        'Serve over the rice.',
  );

  controller.updateMeal(
    controller.findByName('Tacos al Pastor')!,
    cookTimeMinutes: 45,
    servings: 4,
    tags: const {},
    ingredients: [
      Ingredient(quantity: 600, unit: 'g', name: 'pork shoulder'),
      Ingredient(quantity: 150, unit: 'g', name: 'pineapple'),
      Ingredient(quantity: 8, name: 'tortillas'),
      Ingredient(quantity: 1, name: 'onion'),
      Ingredient(name: 'cilantro, to taste'),
      Ingredient(quantity: 2, name: 'limes'),
      Ingredient(quantity: 2, unit: 'tbsp', name: 'achiote paste'),
    ],
    instructions: 'Marinate the pork shoulder in achiote paste for at least an hour.\n'
        'Dice the pineapple and onion, and chop the cilantro.\n'
        'Sear the marinated pork in a hot pan until cooked through and slightly charred.\n'
        'Chop the cooked pork into small pieces.\n'
        'Warm the tortillas in a dry pan.\n'
        'Fill each tortilla with pork, pineapple, onion, and cilantro.\n'
        'Serve with lime wedges.',
  );

  return controller;
}

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
  final _mealListController = _buildDefaultMealListController();
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
