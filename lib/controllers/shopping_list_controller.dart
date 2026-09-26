import 'package:flutter/foundation.dart';

import '../utils/calendar_math.dart';

/// Owns which shopping-list items have been checked off, per week. Checked
/// state is keyed by week start + ingredient key so it's independent per week
/// (and survives the underlying meal schedule regenerating the same item).
class ShoppingListController extends ChangeNotifier {
  final Set<String> _checked = {};

  String _keyFor(DateTime weekAnchor, String itemKey) => '${CalendarMath.startOfWeek(weekAnchor).toIso8601String()}|$itemKey';

  bool isChecked(DateTime weekAnchor, String itemKey) => _checked.contains(_keyFor(weekAnchor, itemKey));

  void toggle(DateTime weekAnchor, String itemKey) {
    final key = _keyFor(weekAnchor, itemKey);
    if (!_checked.remove(key)) {
      _checked.add(key);
    }
    notifyListeners();
  }
}
