import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/main.dart';

/// Uses the wide (desktop) layout so every control stays on-screen without scrolling.
void _useDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('adds a trimmed food to the wheel', (tester) async {
    _useDesktopViewport(tester);
    await tester.pumpWidget(const DishDashApp());

    await tester.enterText(find.byKey(const Key('food-input')), '  Ramen  ');
    await tester.tap(find.byKey(const Key('add-food-button')));
    await tester.pump();

    expect(find.byKey(const ValueKey('food-item-Ramen')), findsOneWidget);
  });

  testWidgets('rejects a duplicate food (case-insensitive)', (tester) async {
    _useDesktopViewport(tester);
    await tester.pumpWidget(const DishDashApp());

    await tester.enterText(find.byKey(const Key('food-input')), 'tacos');
    await tester.tap(find.byKey(const Key('add-food-button')));
    await tester.pump();

    expect(find.text('That food is already on the wheel.'), findsOneWidget);
  });

  testWidgets('disables removing below the two-food minimum', (tester) async {
    _useDesktopViewport(tester);
    await tester.pumpWidget(const DishDashApp());

    // Starting foods: Tacos, Pasta, Curry, Stir-fry. Remove down to the floor.
    await tester.tap(find.descendant(
      of: find.byKey(const ValueKey('food-item-Stir-fry')),
      matching: find.byIcon(Icons.close),
    ));
    await tester.pump();
    await tester.tap(find.descendant(
      of: find.byKey(const ValueKey('food-item-Curry')),
      matching: find.byIcon(Icons.close),
    ));
    await tester.pump();

    final remainingRemoveButtons = tester.widgetList<IconButton>(
      find.ancestor(of: find.byIcon(Icons.close), matching: find.byType(IconButton)),
    );
    expect(remainingRemoveButtons.every((button) => button.onPressed == null), isTrue);
  });

  testWidgets('selects a food once the spin animation completes', (tester) async {
    _useDesktopViewport(tester);
    await tester.pumpWidget(const DishDashApp());

    await tester.tap(find.byKey(const Key('spin-button')));
    await tester.pump();
    expect(find.text('Spinning...'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 3300));

    expect(find.byKey(const Key('result-text')), findsOneWidget);
    expect(find.text('Spin the wheel'), findsOneWidget);
  });
}

