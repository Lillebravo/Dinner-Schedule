import 'package:flutter/material.dart';

import '../controllers/food_list_controller.dart';
import '../controllers/wheel_spin_controller.dart';
import '../models/food.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/food/food_panel.dart';
import '../widgets/wheel/spin_result_label.dart';
import '../widgets/wheel/wheel_display.dart';
import '../widgets/wheel_intro.dart';

class DinnerWheelPage extends StatefulWidget {
  const DinnerWheelPage({super.key});

  @override
  State<DinnerWheelPage> createState() => _DinnerWheelPageState();
}

class _DinnerWheelPageState extends State<DinnerWheelPage> with SingleTickerProviderStateMixin {
  final _foodListController = FoodListController(['Tacos', 'Pasta', 'Curry', 'Stir-fry']);
  final _foodInputController = TextEditingController();
  late final WheelSpinController _spinController;
  String? _selectedFood;

  @override
  void initState() {
    super.initState();
    _spinController = WheelSpinController(vsync: this);
    _foodListController.addListener(_onControllerChanged);
    _spinController.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _foodListController.removeListener(_onControllerChanged);
    _spinController.removeListener(_onControllerChanged);
    _spinController.dispose();
    _foodListController.dispose();
    _foodInputController.dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _addFood() {
    final added = _foodListController.add(_foodInputController.text);
    if (added) {
      _foodInputController.clear();
      setState(() => _selectedFood = null);
    }
  }

  void _spin() {
    final foods = _foodListController.foods;
    _spinController.spin(foods.length, onSettled: (index) {
      setState(() => _selectedFood = foods[index].name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final foods = _foodListController.foods;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 840;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeader(),
                    const SizedBox(height: 40),
                    const WheelIntro(),
                    const SizedBox(height: 40),
                    isNarrow
                        ? Column(
                            children: [
                              _buildWheelStage(foods),
                              const SizedBox(height: 40),
                              _buildFoodPanel(foods),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 13, child: _buildWheelStage(foods)),
                              const SizedBox(width: 48),
                              Expanded(flex: 7, child: _buildFoodPanel(foods)),
                            ],
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWheelStage(List<Food> foods) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wheelSize = constraints.maxWidth.clamp(220.0, 420.0);
        return Column(
          children: [
            WheelDisplay(
              foods: [for (final food in foods) food.name],
              rotation: _spinController.rotationAnimation,
              size: wheelSize,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              key: const Key('spin-button'),
              label: _spinController.spinning ? 'Spinning...' : 'Spin the wheel',
              onPressed: _spinController.spinning ? null : _spin,
            ),
            const SizedBox(height: 20),
            SpinResultLabel(selectedFood: _selectedFood),
          ],
        );
      },
    );
  }

  Widget _buildFoodPanel(List<Food> foods) {
    return FoodPanel(
      foods: foods,
      inputController: _foodInputController,
      onAdd: _addFood,
      onRemove: _foodListController.remove,
      canRemove: !_spinController.spinning && !_foodListController.isAtMinimum,
      error: _foodListController.error,
    );
  }
}
