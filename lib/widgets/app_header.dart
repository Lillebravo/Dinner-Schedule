import 'package:flutter/material.dart';

import '../controllers/theme_mode_controller.dart';
import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';
import 'common/eyebrow_label.dart';

/// Top logo mark, page eyebrow, and the language/theme toggle buttons.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.themeModeController});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final locale = AppLocale.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: colors.coral,
              child: const Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            Text('DishDash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colors.ink)),
          ],
        ),
        Row(
          children: [
            EyebrowLabel(tr(context, 'header.eyebrow')),
            const SizedBox(width: 4),
            IconButton(
              key: const Key('language-toggle-button'),
              tooltip: tr(context, 'header.languageTooltip'),
              onPressed: locale.cycleLanguage,
              icon: const Icon(Icons.translate),
            ),
            IconButton(
              key: const Key('theme-toggle-button'),
              tooltip: tr(context, themeModeController.isDark ? 'header.themeTooltipDark' : 'header.themeTooltipLight'),
              onPressed: themeModeController.toggle,
              icon: Icon(themeModeController.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

