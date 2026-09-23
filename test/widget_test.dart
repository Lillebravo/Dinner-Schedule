import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/main.dart';
import 'package:dishdash/pages/eating_out_wheel_page.dart';
import 'package:dishdash/pages/home_meals_list_page.dart';
import 'package:dishdash/pages/home_wheel_page.dart';

/// Uses the wide (desktop) layout so every control stays on-screen without scrolling.
void _useDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _goTo(WidgetTester tester, String navKey) async {
  await tester.tap(find.byKey(Key(navKey)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens on the home cooking wheel', (tester) async {
    _useDesktopViewport(tester);
    await tester.pumpWidget(const DishDashApp());

    expect(find.text('Let the wheel pick dinner.'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(HomeWheelPage), matching: find.byKey(const Key('spin-button'))),
      findsOneWidget,
    );
  });

  group('eating out wheel', () {
    Finder inTab(Finder matching) => find.descendant(of: find.byType(EatingOutWheelPage), matching: matching);

    testWidgets('adds a trimmed place to the wheel', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-eating-out');

      await tester.enterText(inTab(find.byKey(const Key('food-input'))), '  Ramen House  ');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      expect(inTab(find.byKey(const ValueKey('food-item-Ramen House'))), findsOneWidget);
    });

    testWidgets('rejects a duplicate place (case-insensitive)', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-eating-out');

      await tester.enterText(inTab(find.byKey(const Key('food-input'))), 'sushi bar');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      expect(inTab(find.text('That food is already on the wheel.')), findsOneWidget);
    });

    testWidgets('disables removing below the two-place minimum', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-eating-out');

      await tester.tap(inTab(find.descendant(
        of: find.byKey(const ValueKey('food-item-Taco Truck')),
        matching: find.byIcon(Icons.close),
      )));
      await tester.pump();
      await tester.tap(inTab(find.descendant(
        of: find.byKey(const ValueKey('food-item-Pizzeria')),
        matching: find.byIcon(Icons.close),
      )));
      await tester.pump();

      final remainingRemoveButtons = tester.widgetList<IconButton>(
        inTab(find.ancestor(of: find.byIcon(Icons.close), matching: find.byType(IconButton))),
      );
      expect(remainingRemoveButtons.every((button) => button.onPressed == null), isTrue);
    });

    testWidgets('selects a place once the spin animation completes', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-eating-out');

      await tester.tap(inTab(find.byKey(const Key('spin-button'))));
      await tester.pump();
      expect(inTab(find.text('Spinning...')), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 3300));

      expect(inTab(find.byKey(const Key('result-text'))), findsOneWidget);
      expect(inTab(find.text('Spin the wheel')), findsOneWidget);
    });
  });

  group('home meals list', () {
    Finder inTab(Finder matching) => find.descendant(of: find.byType(HomeMealsListPage), matching: matching);

    testWidgets('adds a trimmed meal to the list', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.enterText(inTab(find.byKey(const Key('food-input'))), '  Fried Rice  ');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      expect(inTab(find.byKey(const ValueKey('meal-item-Fried Rice'))), findsOneWidget);
    });

    testWidgets('rejects a duplicate meal (case-insensitive)', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.enterText(inTab(find.byKey(const Key('food-input'))), 'tacos al pastor');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      expect(inTab(find.text('That meal is already on the list.')), findsOneWidget);
    });

    testWidgets('toggles favorite state', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      final favoriteButton = inTab(find.byKey(const Key('favorite-Tacos al Pastor')));
      expect(tester.widget<IconButton>(favoriteButton).icon, isA<Icon>().having((icon) => icon.icon, 'icon', Icons.star_border));

      await tester.tap(favoriteButton);
      await tester.pump();

      expect(tester.widget<IconButton>(favoriteButton).icon, isA<Icon>().having((icon) => icon.icon, 'icon', Icons.star));
    });

    testWidgets('sorting A-Z reorders the visible meals', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.byKey(const Key('sort-menu-button'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sort-option-name')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      final chickenY = tester.getTopLeft(inTab(find.text('Chicken Stir-fry'))).dy;
      final veggieY = tester.getTopLeft(inTab(find.text('Veggie Curry'))).dy;
      expect(chickenY, lessThan(veggieY));
    });

    testWidgets('tagging a meal lets the vegetarian filter narrow the list', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.text('Veggie Curry')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tag-vegetarian')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      await tester.tap(inTab(find.byKey(const Key('filter-menu-button'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filter-vegetarian')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(inTab(find.text('Veggie Curry')), findsOneWidget);
      expect(inTab(find.text('Tacos al Pastor')), findsNothing);
    });

    testWidgets('filtering down to nothing shows a helpful message', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.byKey(const Key('filter-menu-button'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('filter-vegetarian')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(inTab(find.byKey(const Key('no-meals-match'))), findsOneWidget);
    });

    testWidgets('editing a meal saves ingredients, instructions, and cook time', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.text('Tacos al Pastor')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('cook-time-input')), '25');
      await tester.enterText(find.byKey(const Key('ingredient-input-0')), 'Pork');
      await tester.enterText(find.byKey(const Key('instructions-input')), 'Marinate, then grill.');
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      expect(inTab(find.text('25 min · 1 ingredients')), findsOneWidget);
    });

    testWidgets('disables removing below the two-meal minimum', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.descendant(
        of: find.byKey(const ValueKey('meal-item-Tacos al Pastor')),
        matching: find.byIcon(Icons.close),
      )));
      await tester.pump();
      await tester.tap(inTab(find.descendant(
        of: find.byKey(const ValueKey('meal-item-Veggie Curry')),
        matching: find.byIcon(Icons.close),
      )));
      await tester.pump();

      final remainingRemoveButtons = tester.widgetList<IconButton>(
        inTab(find.ancestor(of: find.byIcon(Icons.close), matching: find.byType(IconButton))),
      );
      expect(remainingRemoveButtons.every((button) => button.onPressed == null), isTrue);
    });
  });

  group('coming soon sections', () {
    testWidgets('shows placeholders for shopping list and meal plan', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await _goTo(tester, 'nav-shopping-list');
      expect(find.text('Shopping list'), findsOneWidget);

      await _goTo(tester, 'nav-meal-plan');
      expect(find.text('Meal planning'), findsOneWidget);
    });
  });
}

