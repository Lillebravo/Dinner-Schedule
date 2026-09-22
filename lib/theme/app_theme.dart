import 'package:flutter/material.dart';

/// Centralized color palette for the app's warm, editorial look.
class AppColors {
  const AppColors._();

  static const ink = Color(0xFF1F2A24);
  static const muted = Color(0xFF657068);
  static const coral = Color(0xFFE95032);
  static const coralDark = Color(0xFFB93822);
  static const line = Color(0xFFCBD4CA);
  static const background = Color(0xFFF5F1E8);
  static const errorText = Color(0xFFA43A24);
}

/// The app's single [ThemeData], built from [AppColors].
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.coral),
      );
}
