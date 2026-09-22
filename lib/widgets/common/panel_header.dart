import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'eyebrow_label.dart';

/// The eyebrow-label + title (+ optional trailing widget) header shared by the
/// wheel entry and home meal panels.
class PanelHeader extends StatelessWidget {
  const PanelHeader({super.key, required this.eyebrow, required this.title, this.trailing});

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EyebrowLabel(eyebrow),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
