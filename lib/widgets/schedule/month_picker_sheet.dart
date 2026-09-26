import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

const _monthAbbreviations = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// A bottom sheet with all 12 months of a year in a grid, plus arrows to page
/// between years, so the user can jump straight to any month.
class MonthPickerSheet extends StatefulWidget {
  const MonthPickerSheet({super.key, required this.initialMonth});

  /// Any date within the year to open on.
  final DateTime initialMonth;

  @override
  State<MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<MonthPickerSheet> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
  }

  @override
  Widget build(BuildContext context) {
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
                  key: const Key('month-page-previous'),
                  onPressed: () => setState(() => _year--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$_year', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.of(context).ink, fontSize: 16)),
                IconButton(
                  key: const Key('month-page-next'),
                  onPressed: () => setState(() => _year++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 56,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2)),
                  child: OutlinedButton(
                    key: Key('month-option-$_year-$month'),
                    onPressed: () => Navigator.of(context).pop(DateTime(_year, month)),
                    child: Text(_monthAbbreviations[month - 1]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
