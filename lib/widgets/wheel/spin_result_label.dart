import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Announces the spin outcome, or a placeholder before the first spin.
class SpinResultLabel extends StatelessWidget {
  const SpinResultLabel({super.key, required this.selectedFood});

  final String? selectedFood;

  @override
  Widget build(BuildContext context) {
    final food = selectedFood;
    return Semantics(
      liveRegion: true,
      child: food != null
          ? Column(
              children: [
                const Text('Dinner is decided', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(
                  food,
                  key: const Key('result-text'),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ],
            )
          : const Text('Your pick will appear here', key: Key('result-placeholder'), style: TextStyle(color: AppColors.muted)),
    );
  }
}
