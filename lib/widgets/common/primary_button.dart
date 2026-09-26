import 'package:flutter/material.dart';

/// The app's primary action button style - matches the OutlinedButton look used
/// for the meal-planner's "Add meal"/"Eat out" buttons (rather than a filled
/// ElevatedButton), since that reads correctly in both light and dark mode via
/// the theme's ColorScheme instead of a hardcoded background color.
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding,
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(label),
    );
  }
}

