import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common/eyebrow_label.dart';

/// Top logo mark and page eyebrow.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.coral,
              child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 10),
            const Text('DishDash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
          ],
        ),
        const EyebrowLabel('DINNER DECISION MAKER'),
      ],
    );
  }
}
