import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import 'spin_result_label.dart';
import 'wheel_display.dart';

/// A wheel, its spin button, and the result label - the part shared by every
/// wheel page, regardless of what it's spinning.
class WheelStage extends StatelessWidget {
  const WheelStage({
    super.key,
    required this.entries,
    required this.rotation,
    required this.spinning,
    required this.onSpin,
    required this.selectedEntry,
    this.emptyHint,
    this.scheduleAction,
  });

  final List<String> entries;
  final Animation<double> rotation;
  final bool spinning;
  final VoidCallback? onSpin;
  final String? selectedEntry;
  final String? emptyHint;

  /// Shown below the result once a winner is picked, letting the user add it
  /// straight to the meal schedule.
  final Widget? scheduleAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wheelSize = constraints.maxWidth.clamp(220.0, 420.0);
        return Column(
          children: [
            WheelDisplay(foods: entries, rotation: rotation, size: wheelSize),
            const SizedBox(height: 28),
            if (entries.length < 2 && emptyHint != null)
              Text(emptyHint!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted))
            else
              PrimaryButton(
                key: const Key('spin-button'),
                label: spinning ? 'Spinning...' : 'Spin the wheel',
                onPressed: spinning ? null : onSpin,
              ),
            const SizedBox(height: 20),
            SpinResultLabel(selectedFood: selectedEntry),
            if (selectedEntry != null && scheduleAction != null) ...[
              const SizedBox(height: 8),
              scheduleAction!,
            ],
          ],
        );
      },
    );
  }
}
