import 'package:flutter/material.dart';

import 'dinner_wheel_page.dart';

void main() {
  runApp(const DishDashApp());
}

class DishDashApp extends StatelessWidget {
  const DishDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DishDash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F1E8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE95032)),
      ),
      home: const DinnerWheelPage(),
    );
  }
}
