import 'package:flutter/material.dart';

import 'controllers/theme_mode_controller.dart';
import 'l10n/app_locale.dart';
import 'l10n/locale_controller.dart';
import 'pages/main_shell.dart';
import 'theme/app_theme.dart';

class DishDashApp extends StatefulWidget {
  const DishDashApp({super.key});

  @override
  State<DishDashApp> createState() => _DishDashAppState();
}

class _DishDashAppState extends State<DishDashApp> {
  final _themeModeController = ThemeModeController();
  final _localeController = LocaleController();

  @override
  void initState() {
    super.initState();
    _themeModeController.addListener(_onChanged);
    _localeController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _themeModeController.removeListener(_onChanged);
    _localeController.removeListener(_onChanged);
    _themeModeController.dispose();
    _localeController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AppLocale(
      controller: _localeController,
      child: MaterialApp(
        title: 'DishDash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeModeController.mode,
        home: MainShell(themeModeController: _themeModeController),
      ),
    );
  }
}

