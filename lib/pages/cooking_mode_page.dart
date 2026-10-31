import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../models/ingredient.dart';
import '../models/meal.dart';
import '../theme/app_theme.dart';
import '../utils/quantity_format.dart';
import '../utils/recipe_steps.dart';
import '../widgets/common/eyebrow_label.dart';
import '../widgets/common/primary_button.dart';

/// A full-screen, distraction-free view of [meal]'s recipe: a servings
/// stepper and ingredients checklist up top (scaling live as servings
/// change), then one instruction step at a time with Previous/Next
/// navigation, so the cook isn't stuck scrolling a dense wall of text while
/// their hands are busy.
class CookingModePage extends StatefulWidget {
  const CookingModePage({super.key, required this.meal});

  final Meal meal;

  @override
  State<CookingModePage> createState() => _CookingModePageState();
}

class _CookingModePageState extends State<CookingModePage> {
  int _stepIndex = 0;
  bool _ingredientsExpanded = false;
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.meal.servings;
  }

  void _setServings(int servings) => setState(() => _servings = servings < 1 ? 1 : servings);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final steps = RecipeSteps.from(widget.meal.instructions);
    final isLastStep = steps.isEmpty || _stepIndex == steps.length - 1;
    final scaleFactor = _servings / widget.meal.servings;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EyebrowLabel(tr(context, 'cookingMode.eyebrow')),
                          const SizedBox(height: 4),
                          Text(widget.meal.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: colors.ink)),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('cooking-mode-close-button'),
                      icon: const Icon(Icons.close),
                      tooltip: tr(context, 'cookingMode.close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ServingsStepper(servings: _servings, onChanged: _setServings),
                if (widget.meal.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _IngredientsPanel(
                    ingredients: [for (final ingredient in widget.meal.ingredients) ingredient.scaled(scaleFactor)],
                    expanded: _ingredientsExpanded,
                    onToggle: () => setState(() => _ingredientsExpanded = !_ingredientsExpanded),
                  ),
                ],
                const SizedBox(height: 24),
                Expanded(
                  child: steps.isEmpty
                      ? Center(
                          child: Text(
                            tr(context, 'cookingMode.noInstructions'),
                            key: const Key('cooking-mode-no-instructions'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.muted, fontSize: 16),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr(context, 'cookingMode.stepLabel', {'current': '${_stepIndex + 1}', 'total': '${steps.length}'}),
                                key: const Key('cooking-mode-step-label'),
                                style: TextStyle(color: colors.coral, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.1),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                steps[_stepIndex],
                                key: const Key('cooking-mode-step-text'),
                                style: TextStyle(color: colors.ink, fontSize: 24, height: 1.4, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                ),
                if (steps.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('cooking-mode-previous-button'),
                          onPressed: _stepIndex == 0 ? null : () => setState(() => _stepIndex -= 1),
                          style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder(), padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: Text(tr(context, 'cookingMode.previous')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          key: const Key('cooking-mode-next-button'),
                          label: tr(context, isLastStep ? 'cookingMode.finish' : 'cookingMode.next'),
                          onPressed: () {
                            if (isLastStep) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() => _stepIndex += 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({required this.servings, required this.onChanged});

  final int servings;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Text(tr(context, 'cookingMode.servings'), style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink)),
        const Spacer(),
        IconButton(
          key: const Key('cooking-mode-servings-decrement'),
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: servings <= 1 ? null : () => onChanged(servings - 1),
        ),
        Text('$servings', key: const Key('cooking-mode-servings-value'), style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink, fontSize: 16)),
        IconButton(
          key: const Key('cooking-mode-servings-increment'),
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(servings + 1),
        ),
      ],
    );
  }
}

class _IngredientsPanel extends StatelessWidget {
  const _IngredientsPanel({required this.ingredients, required this.expanded, required this.onToggle});

  final List<Ingredient> ingredients;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(border: Border.all(color: colors.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('cooking-mode-ingredients-toggle'),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr(context, 'cookingMode.ingredients', {'count': '${ingredients.length}'}),
                      style: TextStyle(fontWeight: FontWeight.w700, color: colors.ink),
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, color: colors.muted),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final ingredient in ingredients)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('\u2022 ${_formatIngredient(ingredient)}', style: TextStyle(color: colors.ink)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatIngredient(Ingredient ingredient) {
    if (ingredient.quantity == null) return ingredient.name;
    return '${QuantityFormat.withUnit(ingredient.quantity!, ingredient.unit)} ${ingredient.name}';
  }
}
