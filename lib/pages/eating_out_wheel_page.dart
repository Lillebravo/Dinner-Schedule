import 'package:flutter/material.dart';

import '../controllers/food_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../controllers/wheel_spin_controller.dart';
import '../l10n/app_locale.dart';
import '../l10n/food_name_translations.dart';
import '../models/scheduled_dinner.dart';
import '../widgets/common/section_intro.dart';
import '../widgets/food/food_panel.dart';
import '../widgets/schedule/add_to_schedule_button.dart';
import '../widgets/wheel/wheel_stage.dart';

/// Spins a wheel of restaurants and takeout spots the user wants to try.
class EatingOutWheelPage extends StatefulWidget {
  const EatingOutWheelPage({super.key, required this.controller, required this.scheduleController});

  final FoodListController controller;
  final MealScheduleController scheduleController;

  @override
  State<EatingOutWheelPage> createState() => _EatingOutWheelPageState();
}

class _EatingOutWheelPageState extends State<EatingOutWheelPage> with SingleTickerProviderStateMixin {
  final _inputController = TextEditingController();
  late final WheelSpinController _spinController;
  String? _selectedFood;

  @override
  void initState() {
    super.initState();
    _spinController = WheelSpinController(vsync: this);
    widget.controller.addListener(_onChanged);
    _spinController.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _spinController.removeListener(_onChanged);
    _spinController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _addFood() {
    if (widget.controller.add(_inputController.text)) {
      _inputController.clear();
      setState(() => _selectedFood = null);
    }
  }

  void _spin() {
    final foods = widget.controller.foods;
    _spinController.spin(foods.length, onSettled: (index) {
      setState(() => _selectedFood = foods[index].name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final foods = widget.controller.foods;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 840;
            final stage = WheelStage(
              entries: [for (final food in foods) translateFoodName(context, food.name)],
              rotation: _spinController.rotationAnimation,
              spinning: _spinController.spinning,
              onSpin: _spin,
              selectedEntry: _selectedFood == null ? null : translateFoodName(context, _selectedFood!),
              emptyHint: tr(context, 'eatingOut.emptyHint'),
              scheduleAction: _selectedFood == null
                  ? null
                  : AddToScheduleButton(
                      title: _selectedFood!,
                      type: DinnerType.eatingOut,
                      scheduleController: widget.scheduleController,
                    ),
            );
            final panel = FoodPanel(
              foods: foods,
              inputController: _inputController,
              onAdd: _addFood,
              onRemove: widget.controller.remove,
              canRemove: !_spinController.spinning && !widget.controller.isAtMinimum,
              error: widget.controller.error,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionIntro(
                  eyebrow: tr(context, 'eatingOut.eyebrow'),
                  headline: tr(context, 'eatingOut.headline'),
                  subtitle: tr(context, 'eatingOut.subtitle'),
                ),
                const SizedBox(height: 40),
                isNarrow
                    ? Column(children: [stage, const SizedBox(height: 40), panel])
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 13, child: stage),
                          const SizedBox(width: 48),
                          Expanded(flex: 7, child: panel),
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
