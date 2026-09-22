import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'eyebrow_label.dart';

/// Eyebrow label + large headline + supporting copy, used atop every page.
class SectionIntro extends StatelessWidget {
  const SectionIntro({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.subtitle,
    this.eyebrowColor = AppColors.coralDark,
  });

  final String eyebrow;
  final Color eyebrowColor;
  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowLabel(eyebrow, color: eyebrowColor),
        const SizedBox(height: 12),
        Text(headline, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.05)),
        const SizedBox(height: 14),
        Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 16, height: 1.5)),
      ],
    );
  }
}
