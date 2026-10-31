import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/controllers/food_list_controller.dart';
import 'package:dishdash/controllers/meal_list_controller.dart';
import 'package:dishdash/controllers/meal_schedule_controller.dart';
import 'package:dishdash/l10n/app_locale.dart';
import 'package:dishdash/l10n/locale_controller.dart';
import 'package:dishdash/main.dart';
import 'package:dishdash/pages/eating_out_wheel_page.dart';
import 'package:dishdash/pages/home_meals_list_page.dart';
import 'package:dishdash/pages/home_wheel_page.dart';
import 'package:dishdash/pages/meal_plan_page.dart';
import 'package:dishdash/pages/shopping_list_page.dart';
import 'package:dishdash/theme/app_theme.dart';
import 'package:dishdash/widgets/schedule/month_day_cell.dart';

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

/// Picks [name] in an already-open [DinnerPickerSheet]'s home-cooked tab and
/// confirms the servings step that follows, accepting whatever serving count
/// is defaulted in.
Future<void> _pickHomeCookedMeal(WidgetTester tester, String name) async {
  await tester.tap(find.byKey(Key('dinner-picker-option-$name')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('dinner-picker-confirm')));
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

      await tester.enterText(inTab(find.byKey(const Key('food-input'))), 'sushi');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      expect(inTab(find.text('That food is already on the wheel.')), findsOneWidget);
    });

    testWidgets('disables removing below the two-place minimum', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-eating-out');

      // Default list has 14 meals; remove all but 2 to hit the minimum.
      for (final name in [
        'Burgers', 'Pizza', 'Tacos', 'Ramen', 'Thai',
        'Italian', 'Chinese', 'Indian', 'Korean', 'Kebab', 'Steakhouse', 'Salad',
      ]) {
        await tester.tap(inTab(find.descendant(
          of: find.byKey(ValueKey('food-item-$name')),
          matching: find.byIcon(Icons.close),
        )));
        await tester.pump();
      }

      final remainingRemoveButtons = tester.widgetList<IconButton>(
        inTab(find.ancestor(of: find.byIcon(Icons.close), matching: find.byType(IconButton))),
      );
      expect(remainingRemoveButtons.every((button) => button.onPressed == null), isTrue);
    });

    testWidgets('selects a place once the spin animation completes', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-eating-out');

      await tester.ensureVisible(inTab(find.byKey(const Key('spin-button'))));
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
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
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

      // Use a freshly-added meal (rather than one of the pre-filled defaults)
      // so it starts with a single blank ingredient row.
      await tester.enterText(inTab(find.byKey(const Key('food-input'))), 'Fish Tacos');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      await tester.tap(inTab(find.text('Fish Tacos')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('cook-time-input')), '25');
      await tester.enterText(find.byKey(const Key('ingredient-input-0')), 'Pork');
      await tester.enterText(find.byKey(const Key('instructions-input')), 'Marinate, then grill.');
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      expect(inTab(find.text('25 min · 1 ingredients')), findsOneWidget);
    });

    testWidgets('cooking mode button is disabled until the meal has instructions', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      // Use a freshly-added meal (rather than one of the pre-filled defaults)
      // so it starts with no instructions.
      await tester.enterText(inTab(find.byKey(const Key('food-input'))), 'Fish Tacos');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      final cookingModeButton = inTab(find.byKey(const Key('cooking-mode-Fish Tacos')));
      expect(tester.widget<IconButton>(cookingModeButton).onPressed, isNull);
    });

    testWidgets('starting cooking mode steps through instructions one at a time', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.text('Tacos al Pastor')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('instructions-input')), 'Marinate the pork.\nGrill until charred.\nAssemble the tacos.');
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      await tester.tap(inTab(find.byKey(const Key('cooking-mode-Tacos al Pastor'))));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Marinate the pork.'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(find.byKey(const Key('cooking-mode-previous-button'))).onPressed, isNull);

      await tester.tap(find.byKey(const Key('cooking-mode-next-button')));
      await tester.pump();
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('Grill until charred.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cooking-mode-next-button')));
      await tester.pump();
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cooking-mode-previous-button')));
      await tester.pump();
      expect(find.text('Step 2 of 3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cooking-mode-next-button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('cooking-mode-next-button')));
      await tester.pumpAndSettle();

      // Finishing pops back to the meals list.
      expect(inTab(find.text('Tacos al Pastor')), findsOneWidget);
    });

    testWidgets('cooking mode scales ingredient quantities live with the servings stepper', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.text('Tacos al Pastor')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('servings-input')), '2');
      await tester.enterText(find.byKey(const Key('ingredient-quantity-0')), '2');
      await tester.enterText(find.byKey(const Key('ingredient-unit-0')), 'cups');
      await tester.enterText(find.byKey(const Key('ingredient-input-0')), 'Salsa');
      await tester.enterText(find.byKey(const Key('instructions-input')), 'Serve warm.');
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      await tester.tap(inTab(find.byKey(const Key('cooking-mode-Tacos al Pastor'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cooking-mode-ingredients-toggle')));
      await tester.pump();

      expect(find.textContaining('2 cups Salsa'), findsOneWidget);

      // Bump servings from 2 to 4 (double): the ingredient amount should double too.
      await tester.tap(find.byKey(const Key('cooking-mode-servings-increment')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('cooking-mode-servings-increment')));
      await tester.pump();

      expect(find.textContaining('4 cups Salsa'), findsOneWidget);
    });

    testWidgets('a fraction quantity in grams displays tight against the unit, not as a fraction', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.text('Tacos al Pastor')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('ingredient-quantity-0')), '1/2');
      await tester.enterText(find.byKey(const Key('ingredient-unit-0')), 'kg');
      await tester.enterText(find.byKey(const Key('ingredient-input-0')), 'Beef');
      await tester.enterText(find.byKey(const Key('instructions-input')), 'Serve warm.');
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      await tester.tap(inTab(find.byKey(const Key('cooking-mode-Tacos al Pastor'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cooking-mode-ingredients-toggle')));
      await tester.pump();

      expect(find.textContaining('0.5kg Beef'), findsOneWidget);
    });

    testWidgets('choosing a preconfigured unit from the dropdown still shows hg as a decimal', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(inTab(find.text('Tacos al Pastor')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('ingredient-quantity-0')), '50.5');
      await tester.enterText(find.byKey(const Key('ingredient-input-0')), 'Flour');

      // Open the unit dropdown and pick "hg" instead of typing it.
      await tester.tap(find.byKey(const Key('ingredient-unit-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('hg').hitTestable());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('instructions-input')), 'Serve warm.');
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      await tester.tap(inTab(find.byKey(const Key('cooking-mode-Tacos al Pastor'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cooking-mode-ingredients-toggle')));
      await tester.pump();

      expect(find.textContaining('50.5hg Flour'), findsOneWidget);
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

  group('shopping list', () {
    Finder inTab(Finder matching) => find.descendant(of: find.byType(ShoppingListPage), matching: matching);

    testWidgets('shows an empty state when no home-cooked meals are scheduled this week', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await _goTo(tester, 'nav-shopping-list');
      expect(inTab(find.textContaining('No home-cooked meals scheduled')), findsOneWidget);
    });

    testWidgets("auto-populates from a scheduled meal's ingredients and can check items off", (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await _goTo(tester, 'nav-home-list');
      await tester.tap(find.text('Tacos al Pastor'));
      await tester.pumpAndSettle();
      // Clear out the pre-filled quantity/unit too, so this ingredient shows
      // up as a plain "Salsa Verde" rather than carrying over "600 g". Avoid
      // "Tortillas" specifically since Tacos al Pastor already has one.
      await tester.enterText(find.byKey(const Key('ingredient-quantity-0')), '');
      await tester.enterText(find.byKey(const Key('ingredient-unit-0')), '');
      await tester.enterText(find.byKey(const Key('ingredient-input-0')), 'Salsa Verde');
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      await _goTo(tester, 'nav-meal-plan');
      await tester.tap(find.textContaining('Add meal').first);
      await tester.pumpAndSettle();
      await _pickHomeCookedMeal(tester, 'Tacos al Pastor');

      await _goTo(tester, 'nav-shopping-list');
      expect(inTab(find.text('Salsa Verde')), findsOneWidget);
      expect(
        inTab(find.descendant(of: find.byKey(const Key('shopping-item-salsa verde')), matching: find.textContaining('Tacos al Pastor'))),
        findsOneWidget,
      );

      await tester.tap(inTab(find.byKey(const Key('shopping-item-salsa verde'))));
      await tester.pump();
      final checkbox = tester.widget<CheckboxListTile>(inTab(find.byKey(const Key('shopping-item-salsa verde'))));
      expect(checkbox.value, isTrue);
    });

    testWidgets('stepping to next week clears the list back to the empty state', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await _goTo(tester, 'nav-home-list');
      await tester.tap(find.text('Tacos al Pastor'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('ingredient-quantity-0')), '');
      await tester.enterText(find.byKey(const Key('ingredient-unit-0')), '');
      await tester.enterText(find.byKey(const Key('ingredient-input-0')), 'Salsa Verde');
      await tester.ensureVisible(find.byKey(const Key('save-meal-button')));
      await tester.tap(find.byKey(const Key('save-meal-button')));
      await tester.pumpAndSettle();

      await _goTo(tester, 'nav-meal-plan');
      await tester.tap(find.textContaining('Add meal').first);
      await tester.pumpAndSettle();
      await _pickHomeCookedMeal(tester, 'Tacos al Pastor');

      await _goTo(tester, 'nav-shopping-list');
      expect(inTab(find.text('Salsa Verde')), findsOneWidget);

      await tester.tap(find.byKey(const Key('period-next')));
      await tester.pumpAndSettle();
      expect(inTab(find.text('Salsa Verde')), findsNothing);
      expect(inTab(find.textContaining('No home-cooked meals scheduled')), findsOneWidget);
    });

    testWidgets('supports adding manual items, cycling sort, and hiding bought items', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-shopping-list');

      for (final name in ['Bananas', 'Apples', 'Zucchini']) {
        await tester.enterText(inTab(find.byKey(const Key('food-input'))), name);
        await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
        await tester.pump();
      }

      expect(inTab(find.text('Added manually')), findsNWidgets(3));

      List<String> titles() =>
          tester.widgetList<CheckboxListTile>(inTab(find.byType(CheckboxListTile))).map((tile) => (tile.title as Text).data!).toList();

      // No sort applied yet: natural (insertion) order.
      expect(titles(), ['Bananas', 'Apples', 'Zucchini']);

      await tester.tap(inTab(find.byKey(const Key('shopping-sort-button'))));
      await tester.pumpAndSettle();

      // First tap on "Name": ascending.
      await tester.tap(find.byKey(const Key('shopping-sort-option-name')));
      await tester.pump();
      expect(titles(), ['Apples', 'Bananas', 'Zucchini']);

      // Second tap: descending.
      await tester.tap(find.byKey(const Key('shopping-sort-option-name')));
      await tester.pump();
      expect(titles(), ['Zucchini', 'Bananas', 'Apples']);

      // Third tap: back to no sort (natural order).
      await tester.tap(find.byKey(const Key('shopping-sort-option-name')));
      await tester.pump();
      expect(titles(), ['Bananas', 'Apples', 'Zucchini']);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Check "Zucchini" (manual-2) off, then hide bought items.
      await tester.tap(inTab(find.byKey(const Key('shopping-item-manual-2'))));
      await tester.pump();
      await tester.tap(inTab(find.byKey(const Key('hide-bought-filter'))));
      await tester.pump();
      expect(inTab(find.text('Zucchini')), findsNothing);
      expect(inTab(find.text('Apples')), findsOneWidget);

      // Un-hide, then remove "Apples" (manual-1) directly.
      await tester.tap(inTab(find.byKey(const Key('hide-bought-filter'))));
      await tester.pump();
      await tester.tap(inTab(find.byKey(const Key('shopping-item-remove-manual-1'))));
      await tester.pump();
      expect(inTab(find.text('Apples')), findsNothing);
    });

    testWidgets('marking an item as already have moves it into the "Already have" section', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-shopping-list');

      await tester.enterText(inTab(find.byKey(const Key('food-input'))), 'Napkins');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      expect(inTab(find.byKey(const Key('already-have-header'))), findsNothing);

      await tester.tap(inTab(find.byKey(const Key('shopping-item-stash-manual-0'))));
      await tester.pump();

      expect(inTab(find.text('Already have (1)')), findsOneWidget);
      expect(inTab(find.text('Napkins')), findsOneWidget);

      // Un-marking moves it back out of the section.
      await tester.tap(inTab(find.byKey(const Key('shopping-item-stash-manual-0'))));
      await tester.pump();
      expect(inTab(find.byKey(const Key('already-have-header'))), findsNothing);
    });

    testWidgets('grouping by aisle sorts items under aisle headers, correctable per item', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-shopping-list');

      for (final name in ['Milk', 'Onion', 'Napkins']) {
        await tester.enterText(inTab(find.byKey(const Key('food-input'))), name);
        await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
        await tester.pump();
      }

      await tester.tap(inTab(find.byKey(const Key('group-by-aisle-filter'))));
      await tester.pump();

      expect(inTab(find.byKey(const Key('aisle-header-dairy'))), findsOneWidget);
      expect(inTab(find.byKey(const Key('aisle-header-produce'))), findsOneWidget);
      expect(inTab(find.byKey(const Key('aisle-header-other'))), findsOneWidget);
      expect(inTab(find.text('Milk')), findsOneWidget);
      expect(inTab(find.text('Onion')), findsOneWidget);
      expect(inTab(find.text('Napkins')), findsOneWidget);

      // Correct "Napkins" (guessed as "Other") to "Produce" and confirm "Other" disappears.
      await tester.tap(inTab(find.byKey(const Key('shopping-item-aisle-manual-2'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('aisle-option-manual-2-produce')));
      await tester.pumpAndSettle();

      expect(inTab(find.byKey(const Key('aisle-header-other'))), findsNothing);
      expect(inTab(find.byKey(const Key('aisle-header-produce'))), findsOneWidget);
    });

    testWidgets('done shopping clears checked items off the list', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-shopping-list');

      await tester.enterText(inTab(find.byKey(const Key('food-input'))), 'Napkins');
      await tester.tap(inTab(find.byKey(const Key('add-food-button'))));
      await tester.pump();

      final disabled = tester.widget<TextButton>(inTab(find.byKey(const Key('finish-shopping-button'))));
      expect(disabled.onPressed, isNull);

      await tester.tap(inTab(find.byKey(const Key('shopping-item-manual-0'))));
      await tester.pump();

      final enabled = tester.widget<TextButton>(inTab(find.byKey(const Key('finish-shopping-button'))));
      expect(enabled.onPressed, isNotNull);

      await tester.tap(inTab(find.byKey(const Key('finish-shopping-button'))));
      await tester.pumpAndSettle();

      expect(inTab(find.text('Napkins')), findsNothing);
    });
  });

  group('meal planning', () {
    Finder inTab(Finder matching) => find.descendant(of: find.byType(MealPlanPage), matching: matching);

    testWidgets('defaults to the weekly view with 7 days and lets a meal be added', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-meal-plan');

      expect(inTab(find.text('Weekly')), findsOneWidget);
      expect(inTab(find.textContaining('Week ')), findsOneWidget);
      expect(inTab(find.textContaining('Add meal')), findsNWidgets(7));

      await tester.tap(inTab(find.textContaining('Add meal')).first);
      await tester.pumpAndSettle();
      await _pickHomeCookedMeal(tester, 'Tacos al Pastor');

      expect(inTab(find.text('Tacos al Pastor')), findsOneWidget);
    });

    testWidgets('picking a home-cooked meal defaults and clearly shows its servings, editable from the day card', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-meal-plan');

      await tester.tap(inTab(find.textContaining('Add meal')).first);
      await tester.pumpAndSettle();
      await _pickHomeCookedMeal(tester, 'Tacos al Pastor');

      // Defaults to the recipe's own serving size (4), shown clearly on the day card.
      expect(inTab(find.textContaining('4 servings')), findsOneWidget);

      // Editing it from the day card updates the label.
      await tester.tap(inTab(find.textContaining('4 servings')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('servings-stepper-increment')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('servings-stepper-increment')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('servings-editor-save')));
      await tester.pumpAndSettle();

      expect(inTab(find.textContaining('6 servings')), findsOneWidget);
    });

    testWidgets('can start cooking directly from a day scheduled with a home-cooked meal', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-meal-plan');

      await tester.tap(inTab(find.textContaining('Add meal')).first);
      await tester.pumpAndSettle();
      await _pickHomeCookedMeal(tester, 'Tacos al Pastor');

      await tester.tap(inTab(find.byTooltip('Start cooking')));
      await tester.pumpAndSettle();

      expect(find.text('Tacos al Pastor'), findsOneWidget);
      expect(find.byKey(const Key('cooking-mode-close-button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('cooking-mode-close-button')));
      await tester.pumpAndSettle();
      expect(inTab(find.text('Tacos al Pastor')), findsOneWidget);
    });

    testWidgets("increasing a scheduled day's servings scales its ingredients in the shopping list", (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-meal-plan');

      await tester.tap(inTab(find.textContaining('Add meal')).first);
      await tester.pumpAndSettle();
      await _pickHomeCookedMeal(tester, 'Spaghetti Bolognese');

      // Double the planned servings for this night, from 4 to 8.
      await tester.tap(inTab(find.textContaining('4 servings')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('servings-stepper-increment')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('servings-editor-save')));
      await tester.pumpAndSettle();

      await _goTo(tester, 'nav-shopping-list');
      expect(
        find.descendant(of: find.byType(ShoppingListPage), matching: find.textContaining('1000g ground beef')),
        findsOneWidget,
      );
    });

    testWidgets('fill week assigns meals to every empty day without touching existing ones', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-meal-plan');

      // Manually schedule one day first.
      await tester.tap(inTab(find.textContaining('Add meal')).first);
      await tester.pumpAndSettle();
      await _pickHomeCookedMeal(tester, 'Tacos al Pastor');
      expect(inTab(find.textContaining('Add meal')), findsNWidgets(6));

      await tester.tap(inTab(find.byKey(const Key('fill-week-button'))));
      await tester.pumpAndSettle();

      // Every day now has something scheduled, and the manually-set day is untouched
      // (other days may also land on "Tacos al Pastor" by chance from the shuffle,
      // since there are only 4 meals and 6 empty days to fill).
      expect(inTab(find.textContaining('Add meal')), findsNothing);
      expect(inTab(find.text('Tacos al Pastor')), findsAtLeastNWidgets(1));
      expect(find.textContaining('Filled 6 empty day'), findsOneWidget);

      // Nothing left to fill now, so the button disables itself.
      expect(tester.widget<TextButton>(inTab(find.byKey(const Key('fill-week-button')))).onPressed, isNull);
    });

    testWidgets('switching to monthly shows a calendar grid', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-meal-plan');

      await tester.tap(inTab(find.text('Monthly')));
      await tester.pumpAndSettle();

      expect(inTab(find.byType(MonthDayCell)), findsNWidgets(42));
    });

    testWidgets('monthly view does not overflow on a narrow phone-width layout', (tester) async {
      await tester.pumpWidget(
        AppLocale(
          controller: LocaleController(),
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: MealPlanPage(
                  scheduleController: MealScheduleController(),
                  mealListController: MealListController(const ['Tacos', 'Pasta']),
                  foodListController: FoodListController(const ['Sushi Bar', 'Burger Place']),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('month picker sheet does not overflow on a narrow, large-text viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        AppLocale(
          controller: LocaleController(),
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: MealPlanPage(
                  scheduleController: MealScheduleController(),
                  mealListController: MealListController(const ['Tacos', 'Pasta']),
                  foodListController: FoodListController(const ['Sushi Bar', 'Burger Place']),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Monthly'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('period-label')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('period-label')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(MonthDayCell).first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('offers a quick way back once the user has navigated away from today', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-meal-plan');

      expect(inTab(find.byKey(const Key('jump-to-current-period'))), findsNothing);

      await tester.tap(inTab(find.byKey(const Key('period-next'))));
      await tester.pumpAndSettle();
      expect(inTab(find.text('This week')), findsOneWidget);

      await tester.tap(inTab(find.text('This week')));
      await tester.pumpAndSettle();
      expect(inTab(find.byKey(const Key('jump-to-current-period'))), findsNothing);

      await tester.tap(inTab(find.text('Monthly')));
      await tester.pumpAndSettle();
      expect(inTab(find.byKey(const Key('jump-to-current-period'))), findsNothing);

      await tester.tap(inTab(find.byKey(const Key('period-next'))));
      await tester.pumpAndSettle();
      expect(inTab(find.text('This month')), findsOneWidget);
    });

    testWidgets('spinning the home wheel offers adding the pick to the schedule', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await tester.tap(find.byKey(const Key('spin-button')));
      await tester.pumpAndSettle(const Duration(milliseconds: 3300));

      expect(find.byKey(const Key('add-to-schedule-button')), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('add-to-schedule-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-to-schedule-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tonight'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Added'), findsOneWidget);
    });

    testWidgets('the day picker shows what is already scheduled on a day', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await tester.tap(find.byKey(const Key('spin-button')));
      await tester.pumpAndSettle(const Duration(milliseconds: 3300));
      await tester.ensureVisible(find.byKey(const Key('add-to-schedule-button')));
      await tester.tap(find.byKey(const Key('add-to-schedule-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tonight'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add-to-schedule-button')));
      await tester.tap(find.byKey(const Key('add-to-schedule-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('day-picker-already-planned')), findsOneWidget);
    });

    testWidgets('the day picker fills in a day\'s dot once something is planned', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      final today = DateTime.now();
      final todayDotKey = Key('day-picker-dot-${DateTime(today.year, today.month, today.day).toIso8601String()}');

      Color? dotColor() {
        final container = tester.widget<Container>(find.descendant(of: find.byKey(todayDotKey), matching: find.byType(Container)));
        return (container.decoration as BoxDecoration).color;
      }

      await tester.tap(find.byKey(const Key('spin-button')));
      await tester.pumpAndSettle(const Duration(milliseconds: 3300));
      await tester.ensureVisible(find.byKey(const Key('add-to-schedule-button')));
      await tester.tap(find.byKey(const Key('add-to-schedule-button')));
      await tester.pumpAndSettle();

      expect(dotColor(), isNot(AppColors.light.coral));

      await tester.tap(find.text('Tonight'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('add-to-schedule-button')));
      await tester.tap(find.byKey(const Key('add-to-schedule-button')));
      await tester.pumpAndSettle();

      expect(dotColor(), AppColors.light.coral);
    });

    testWidgets('the day picker\'s custom date fallback has no manual keyboard entry option', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await tester.tap(find.byKey(const Key('spin-button')));
      await tester.pumpAndSettle(const Duration(milliseconds: 3300));
      await tester.ensureVisible(find.byKey(const Key('add-to-schedule-button')));
      await tester.tap(find.byKey(const Key('add-to-schedule-button')));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.byKey(const Key('day-picker-custom-date')),
        find.byType(ListView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('day-picker-custom-date')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('lets a meal be added to the schedule directly from the meals list', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());
      await _goTo(tester, 'nav-home-list');

      await tester.tap(find.byKey(const Key('add-to-schedule-Tacos al Pastor')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tonight'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Added Tacos al Pastor'), findsOneWidget);
    });
  });
}

