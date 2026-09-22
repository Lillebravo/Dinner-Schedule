import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common/eyebrow_label.dart';

/// Page headline and supporting copy above the wheel.
class WheelIntro extends StatelessWidget {
  const WheelIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowLabel("TONIGHT'S MENU", color: AppColors.coralDark),
        const SizedBox(height: 12),
        const Text(
          "Let the wheel pick dinner.",
          style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.0),
        ),
        const SizedBox(height: 14),
        const Text(
          'Add the food you are craving, give it a spin, and leave the debate to chance.',
          style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
}
