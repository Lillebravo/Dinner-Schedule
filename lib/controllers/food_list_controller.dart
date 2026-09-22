import 'package:flutter/foundation.dart';

import '../models/food.dart';

/// Owns the wheel's food entries and enforces the app's validation rules.
class FoodListController extends ChangeNotifier {
  FoodListController([List<String>? initialFoods])
      : _foods = [for (final name in initialFoods ?? const []) Food(name)];

  static const int minFoods = 2;
  static const int maxNameLength = 40;

  final List<Food> _foods;
  String? _error;

  List<Food> get foods => List.unmodifiable(_foods);
  String? get error => _error;
  bool get isAtMinimum => _foods.length <= minFoods;

  /// Adds [rawName] to the wheel after trimming and validating it. Returns true on success.
  bool add(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty || name.length > maxNameLength) {
      _error = 'Enter a food name up to $maxNameLength characters.';
      notifyListeners();
      return false;
    }
    if (_foods.any((food) => food.matchesName(name))) {
      _error = 'That food is already on the wheel.';
      notifyListeners();
      return false;
    }
    _error = null;
    _foods.add(Food(name));
    notifyListeners();
    return true;
  }

  /// Removes [food] unless doing so would drop below [minFoods] entries. Returns
  /// whether the removal happened.
  bool remove(Food food) {
    if (isAtMinimum) return false;
    _foods.remove(food);
    notifyListeners();
    return true;
  }
}
