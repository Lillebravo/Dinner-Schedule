import 'package:flutter/material.dart';

import 'pages/dinner_wheel_page.dart';
import 'theme/app_theme.dart';

class DishDashApp extends StatelessWidget {
  const DishDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DishDash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DinnerWheelPage(),
    );
  }
}
