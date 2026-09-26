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
    testWidgets('shows a placeholder for the shopping list', (tester) async {
      _useDesktopViewport(tester);
      await tester.pumpWidget(const DishDashApp());

      await _goTo(tester, 'nav-shopping-list');
      expect(find.text('Shopping list'), findsOneWidget);
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
      await tester.tap(find.byKey(const Key('dinner-picker-option-Tacos al Pastor')));
      await tester.pumpAndSettle();

      expect(inTab(find.text('Tacos al Pastor')), findsOneWidget);
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

