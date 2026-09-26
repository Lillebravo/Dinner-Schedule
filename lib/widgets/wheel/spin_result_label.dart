import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';

/// Announces the spin outcome, or a placeholder before the first spin.
class SpinResultLabel extends StatelessWidget {
  const SpinResultLabel({super.key, required this.selectedFood});

  final String? selectedFood;

  @override
  Widget build(BuildContext context) {
    final food = selectedFood;
    final colors = AppColors.of(context);
    return Semantics(
      liveRegion: true,
      child: food != null
          ? Column(
              children: [
                Text(tr(context, 'result.decided'), style: TextStyle(color: colors.muted)),
                const SizedBox(height: 4),
                Text(
                  food,
                  key: const Key('result-text'),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.ink),
                ),
              ],
            )
          : Text(tr(context, 'result.placeholder'), key: const Key('result-placeholder'), style: TextStyle(color: colors.muted)),
    );
  }
}

