import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/calendar_math.dart';

const _monthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// A bottom sheet that pages through 4 weeks at a time so the user can jump to
/// an exact week without stepping through the header's single-week arrows.
class WeekPickerSheet extends StatefulWidget {
  const WeekPickerSheet({super.key, required this.initialWeekStart});

  /// The Monday of the week to center the first page on.
  final DateTime initialWeekStart;

  @override
  State<WeekPickerSheet> createState() => _WeekPickerSheetState();
}

class _WeekPickerSheetState extends State<WeekPickerSheet> {
  static const int weeksPerPage = 4;
  late DateTime _pageStart;

  @override
  void initState() {
    super.initState();
    _pageStart = widget.initialWeekStart;
  }

  void _shiftPage(int weeks) => setState(() => _pageStart = _pageStart.add(Duration(days: 7 * weeks)));

  @override
  Widget build(BuildContext context) {
    final weeks = [for (var i = 0; i < weeksPerPage; i++) _pageStart.add(Duration(days: 7 * i))];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  key: const Key('week-page-previous'),
                  onPressed: () => _shiftPage(-weeksPerPage),
                  icon: const Icon(Icons.chevron_left),
                ),
                const Text('Choose a week', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
                IconButton(
                  key: const Key('week-page-next'),
                  onPressed: () => _shiftPage(weeksPerPage),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            for (final week in weeks)
              ListTile(
                key: Key('week-option-${week.toIso8601String()}'),
                title: Text('Week ${CalendarMath.isoWeekNumber(week)}'),
                subtitle: Text(_rangeLabel(week)),
                onTap: () => Navigator.of(context).pop(week),
              ),
          ],
        ),
      ),
    );
  }

  String _rangeLabel(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 6));
    return '${_short(weekStart)} - ${_short(end)}';
  }

  String _short(DateTime day) => '${_monthAbbreviations[day.month - 1]} ${day.day}';
}
