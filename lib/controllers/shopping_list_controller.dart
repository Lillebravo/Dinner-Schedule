import 'package:flutter/foundation.dart';

import '../models/shopping_list_item.dart';
import '../utils/calendar_math.dart';

class _ManualItem {
  _ManualItem({required this.id, required this.name});
  final String id;
  final String name;
}

/// Owns everything about a week's shopping list that isn't derived straight
/// from the meal schedule: which items are checked off, manually-added extra
/// items, and which meal-derived ingredients have been dismissed via
/// [finishShopping]. All keyed by week so it behaves like the schedule -
/// stepping to a different week shows that week's own state.
class ShoppingListController extends ChangeNotifier {
  final Set<String> _checked = {};
  final Set<String> _hiddenAutoItems = {};
  final Map<String, List<_ManualItem>> _manualItemsByWeek = {};
  int _nextManualId = 0;

  static String _weekKey(DateTime weekAnchor) => CalendarMath.startOfWeek(weekAnchor).toIso8601String();
  static String _entryKey(DateTime weekAnchor, String itemKey) => '${_weekKey(weekAnchor)}|$itemKey';

  bool isChecked(DateTime weekAnchor, String itemKey) => _checked.contains(_entryKey(weekAnchor, itemKey));

  void toggle(DateTime weekAnchor, String itemKey) {
    final key = _entryKey(weekAnchor, itemKey);
    if (!_checked.remove(key)) {
      _checked.add(key);
    }
    notifyListeners();
  }

  /// Whether a meal-derived ingredient has been dismissed via [finishShopping]
  /// for this week, so it stops reappearing until the schedule changes again.
  bool isAutoItemHidden(DateTime weekAnchor, String itemKey) => _hiddenAutoItems.contains(_entryKey(weekAnchor, itemKey));

  /// This week's hand-added extra items, oldest first.
  List<ShoppingListItem> manualItemsForWeek(DateTime weekAnchor) {
    final items = _manualItemsByWeek[_weekKey(weekAnchor)] ?? const [];
    return [for (final item in items) ShoppingListItem(name: item.name, count: 1, mealNames: const [], manualId: item.id)];
  }

  /// Adds a free-form item to this week's list, independent of the schedule.
  void addManualItem(DateTime weekAnchor, String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return;
    (_manualItemsByWeek[_weekKey(weekAnchor)] ??= []).add(_ManualItem(id: 'manual-${_nextManualId++}', name: name));
    notifyListeners();
  }

  void removeManualItem(DateTime weekAnchor, String manualId) {
    final list = _manualItemsByWeek[_weekKey(weekAnchor)];
    if (list == null) return;
    final removed = list.length;
    list.removeWhere((item) => item.id == manualId);
    if (list.length != removed) notifyListeners();
  }

  /// Clears every currently-checked item out of [items] for this week: manual
  /// items are deleted outright, meal-derived ingredients are hidden until the
  /// schedule changes (otherwise they'd just reappear on the next rebuild).
  void finishShopping(DateTime weekAnchor, List<ShoppingListItem> items) {
    var changed = false;
    for (final item in items) {
      if (!isChecked(weekAnchor, item.key)) continue;
      if (item.isManual) {
        _manualItemsByWeek[_weekKey(weekAnchor)]?.removeWhere((manual) => manual.id == item.manualId);
      } else {
        _hiddenAutoItems.add(_entryKey(weekAnchor, item.key));
      }
      _checked.remove(_entryKey(weekAnchor, item.key));
      changed = true;
    }
    if (changed) notifyListeners();
  }
}
