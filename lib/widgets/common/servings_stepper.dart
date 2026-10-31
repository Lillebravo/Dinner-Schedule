import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';

/// A "Servings  [-] 4 [+]" row, shared by the meal planner's add/edit flows
/// and cooking mode.
class ServingsStepper extends StatelessWidget {
  const ServingsStepper({super.key, required this.servings, required this.onChanged, this.minServings = 1});

  final int servings;
  final ValueChanged<int> onChanged;
  final int minServings;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Text(tr(context, 'mealPlan.servingsFieldLabel'), style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
        const Spacer(),
        IconButton(
          key: const Key('servings-stepper-decrement'),
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: servings <= minServings ? null : () => onChanged(servings - 1),
        ),
        Text('$servings', key: const Key('servings-stepper-value'), style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink, fontSize: 16)),
        IconButton(
          key: const Key('servings-stepper-increment'),
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(servings + 1),
        ),
      ],
    );
  }
}
