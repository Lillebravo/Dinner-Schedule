import 'package:flutter/material.dart';

/// Centralized color palette for the app's warm, editorial look. Colors are
/// brightness-aware: call [AppColors.of] instead of using static fields
/// directly, so every screen follows the current light/dark mode.
class AppColors {
  const AppColors._({
    required this.ink,
    required this.muted,
    required this.coral,
    required this.coralDark,
    required this.line,
    required this.background,
    required this.surface,
    required this.errorText,
  });

  final Color ink;
  final Color muted;
  final Color coral;
  final Color coralDark;
  final Color line;
  final Color background;
  final Color surface;
  final Color errorText;

  static const light = AppColors._(
    ink: Color(0xFF1F2A24),
    muted: Color(0xFF657068),
    coral: Color(0xFFE95032),
    coralDark: Color(0xFFB93822),
    line: Color(0xFFCBD4CA),
    background: Color(0xFFF5F1E8),
    surface: Colors.white,
    errorText: Color(0xFFA43A24),
  );

  static const dark = AppColors._(
    ink: Color(0xFFEDEAE2),
    muted: Color(0xFFA9B3AC),
    coral: Color(0xFFFF7A5C),
    coralDark: Color(0xFFFFA187),
    line: Color(0xFF3A443C),
    background: Color(0xFF1B211D),
    surface: Color(0xFF262E27),
    errorText: Color(0xFFFF8A6B),
  );

  /// The palette matching the current [Theme]'s brightness.
  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// The app's light and dark [ThemeData], both built from [AppColors].
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.light.coral),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.dark.coral, brightness: Brightness.dark),
      );
}

