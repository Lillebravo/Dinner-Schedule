import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';

/// A bottom sheet for editing a meal's cook time, ingredients, and instructions.
class MealEditSheet extends StatefulWidget {
  const MealEditSheet({super.key, required this.meal, required this.onSave});

  final Meal meal;
  final void Function({
    required List<String> ingredients,
    required String instructions,
    int? cookTimeMinutes,
    required Set<MealTag> tags,
  }) onSave;

  @override
  State<MealEditSheet> createState() => _MealEditSheetState();
}

class _MealEditSheetState extends State<MealEditSheet> {
  late final List<TextEditingController> _ingredientControllers;
  late final TextEditingController _instructionsController;
  late final TextEditingController _cookTimeController;
  late Set<MealTag> _selectedTags;

  @override
  void initState() {
    super.initState();
    final ingredients = widget.meal.ingredients.isEmpty ? [''] : widget.meal.ingredients;
    _ingredientControllers = [for (final ingredient in ingredients) TextEditingController(text: ingredient)];
    _instructionsController = TextEditingController(text: widget.meal.instructions);
    _cookTimeController = TextEditingController(text: widget.meal.cookTimeMinutes?.toString() ?? '');
    _selectedTags = Set.of(widget.meal.tags);
  }

  @override
  void dispose() {
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    _instructionsController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  void _addIngredientField() => setState(() => _ingredientControllers.add(TextEditingController()));

  void _removeIngredientField(int index) => setState(() => _ingredientControllers.removeAt(index).dispose());

  void _toggleTag(MealTag tag) => setState(() {
        if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
      });

  void _save() {
    final ingredients = [
      for (final controller in _ingredientControllers)
        if (controller.text.trim().isNotEmpty) controller.text.trim(),
    ];
    widget.onSave(
      ingredients: ingredients,
      instructions: _instructionsController.text.trim(),
      cookTimeMinutes: int.tryParse(_cookTimeController.text.trim()),
      tags: _selectedTags,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.meal.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 16),
            TextField(
              key: const Key('cook-time-input'),
              controller: _cookTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Time to cook (minutes)', border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
            ),
            const SizedBox(height: 16),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in MealTag.values)
                  FilterChip(
                    key: Key('tag-${tag.name}'),
                    label: Text(tag.label),
                    selected: _selectedTags.contains(tag),
                    onSelected: (_) => _toggleTag(tag),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 8),
            for (var i = 0; i < _ingredientControllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: Key('ingredient-input-$i'),
                        controller: _ingredientControllers[i],
                        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _removeIngredientField(i)),
                  ],
                ),
              ),
            TextButton.icon(
              key: const Key('add-ingredient-button'),
              onPressed: _addIngredientField,
              icon: const Icon(Icons.add),
              label: const Text('Add ingredient'),
            ),
            const SizedBox(height: 16),
            const Text('Instructions', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 8),
            TextField(
              key: const Key('instructions-input'),
              controller: _instructionsController,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
            ),
            const SizedBox(height: 20),
            PrimaryButton(key: const Key('save-meal-button'), label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
