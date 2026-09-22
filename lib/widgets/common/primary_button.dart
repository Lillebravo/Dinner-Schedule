import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The app's dark, square elevated button style, shared by the spin and add actions.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.55),
        disabledForegroundColor: Colors.white,
        padding: padding,
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(label),
    );
  }
}
