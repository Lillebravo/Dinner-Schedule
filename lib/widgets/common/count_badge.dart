import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Circular badge showing how many entries are currently on a list or wheel.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.line)),
      child: Text('$count', style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
