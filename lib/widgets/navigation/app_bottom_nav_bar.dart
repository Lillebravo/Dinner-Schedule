import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';

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
      destinations: [
        NavigationDestination(
          key: const Key('nav-eating-out'),
          icon: const Icon(Icons.restaurant_outlined),
          selectedIcon: const Icon(Icons.restaurant),
          label: tr(context, 'nav.eatOut'),
        ),
        NavigationDestination(
          key: const Key('nav-home-list'),
          icon: const Icon(Icons.list_alt_outlined),
          selectedIcon: const Icon(Icons.list_alt),
          label: tr(context, 'nav.meals'),
        ),
        NavigationDestination(
          key: const Key('nav-home-wheel'),
          icon: const Icon(Icons.casino_outlined),
          selectedIcon: const Icon(Icons.casino),
          label: tr(context, 'nav.spin'),
        ),
        NavigationDestination(
          key: const Key('nav-shopping-list'),
          icon: const Icon(Icons.shopping_cart_outlined),
          selectedIcon: const Icon(Icons.shopping_cart),
          label: tr(context, 'nav.shopping'),
        ),
        NavigationDestination(
          key: const Key('nav-meal-plan'),
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: tr(context, 'nav.plan'),
        ),
      ],
    );
  }
}
