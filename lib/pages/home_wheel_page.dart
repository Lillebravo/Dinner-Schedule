import 'package:flutter/material.dart';

import '../controllers/meal_list_controller.dart';
import '../controllers/meal_schedule_controller.dart';
import '../controllers/wheel_spin_controller.dart';
import '../l10n/app_locale.dart';
import '../models/scheduled_dinner.dart';
import '../widgets/common/section_intro.dart';
import '../widgets/schedule/add_to_schedule_button.dart';
import '../widgets/wheel/wheel_stage.dart';

/// Spins a wheel of the user's own home-cooked meals.
class HomeWheelPage extends StatefulWidget {
  const HomeWheelPage({super.key, required this.controller, required this.scheduleController});

  final MealListController controller;
  final MealScheduleController scheduleController;

  @override
  State<HomeWheelPage> createState() => _HomeWheelPageState();
}

class _HomeWheelPageState extends State<HomeWheelPage> with SingleTickerProviderStateMixin {
  late final WheelSpinController _spinController;
  String? _selectedMeal;

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
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _spin() {
    final meals = widget.controller.meals;
    _spinController.spin(meals.length, onSettled: (index) {
      setState(() => _selectedMeal = meals[index].name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meals = widget.controller.meals;
    final emptyHint = widget.controller.activeFilters.isNotEmpty
        ? tr(context, 'homeWheel.emptyHintFiltered')
        : tr(context, 'homeWheel.emptyHint');
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionIntro(
              eyebrow: tr(context, 'homeWheel.eyebrow'),
              headline: tr(context, 'homeWheel.headline'),
              subtitle: tr(context, 'homeWheel.subtitle'),
            ),
            const SizedBox(height: 40),
            WheelStage(
              entries: [for (final meal in meals) meal.name],
              rotation: _spinController.rotationAnimation,
              spinning: _spinController.spinning,
              onSpin: _spin,
              selectedEntry: _selectedMeal,
              emptyHint: emptyHint,
              scheduleAction: _selectedMeal == null
                  ? null
                  : AddToScheduleButton(
                      title: _selectedMeal!,
                      type: DinnerType.homeCooked,
                      scheduleController: widget.scheduleController,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
