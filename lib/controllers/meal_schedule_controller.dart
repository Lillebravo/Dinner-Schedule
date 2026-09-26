import 'package:flutter/foundation.dart';

import '../models/scheduled_dinner.dart';

/// Owns the meal-planning calendar: at most one [ScheduledDinner] per day, keyed
/// by date (time-of-day is ignored).
class MealScheduleController extends ChangeNotifier {
  final Map<DateTime, ScheduledDinner> _dinners = {};

  /// Strips the time-of-day so [day] can be used as a map key.
  static DateTime normalize(DateTime day) => DateTime(day.year, day.month, day.day);

  ScheduledDinner? dinnerOn(DateTime day) => _dinners[normalize(day)];

  /// Assigns [dinner] to [day], replacing whatever was already scheduled there.
  void setDinner(DateTime day, ScheduledDinner dinner) {
    _dinners[normalize(day)] = dinner;
    notifyListeners();
  }

  /// Clears whatever dinner was scheduled for [day], if any.
  void clearDinner(DateTime day) {
    if (_dinners.remove(normalize(day)) != null) notifyListeners();
  }

  /// Moves the dinner scheduled on [from] to [to] (used for drag-and-drop
  /// rearranging), swapping with whatever was already on [to], if anything.
  /// No-op if [from] has nothing scheduled or the two days are the same.
  void moveDinner(DateTime from, DateTime to) {
    final fromKey = normalize(from);
    final toKey = normalize(to);
    if (fromKey == toKey) return;
    final moving = _dinners[fromKey];
    if (moving == null) return;

    final displaced = _dinners[toKey];
    _dinners[toKey] = moving;
    if (displaced != null) {
      _dinners[fromKey] = displaced;
    } else {
      _dinners.remove(fromKey);
    }
    notifyListeners();
  }
}
