import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The "< Week 27 >" / "< September 2026 >" bar atop the meal-planning schedule.
/// Tapping the label opens a picker (provided by the caller); the arrows step
/// one period (week or month) forward/backward.
class SchedulePeriodHeader extends StatelessWidget {
  const SchedulePeriodHeader({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onTapLabel,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTapLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('period-previous'),
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous',
        ),
        Flexible(
          child: InkWell(
            key: const Key('period-label'),
            onTap: onTapLabel,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.of(context).ink),
              ),
            ),
          ),
        ),
        IconButton(
          key: const Key('period-next'),
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next',
        ),
      ],
    );
  }
}
