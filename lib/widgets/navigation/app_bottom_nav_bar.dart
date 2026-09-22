import 'package:flutter/material.dart';

/// The app's bottom tab bar: eating-out wheel, home meals list, home-cooking
/// wheel (center), shopping list, and meal planning.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      destinations: const [
        NavigationDestination(
          key: Key('nav-eating-out'),
          icon: Icon(Icons.restaurant_outlined),
          selectedIcon: Icon(Icons.restaurant),
          label: 'Eat Out',
        ),
        NavigationDestination(
          key: Key('nav-home-list'),
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Meals',
        ),
        NavigationDestination(
          key: Key('nav-home-wheel'),
          icon: Icon(Icons.casino_outlined),
          selectedIcon: Icon(Icons.casino),
          label: 'Spin',
        ),
        NavigationDestination(
          key: Key('nav-shopping-list'),
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: 'Shopping',
        ),
        NavigationDestination(
          key: Key('nav-meal-plan'),
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Plan',
        ),
      ],
    );
  }
}
