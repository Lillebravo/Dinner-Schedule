import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../models/ingredient.dart';
import '../../models/meal.dart';
import '../../theme/app_theme.dart';
import '../../utils/quantity_format.dart';
import '../common/primary_button.dart';

/// A bottom sheet for editing a meal's cook time, servings, ingredients
/// (quantity + unit + name), and instructions.
class MealEditSheet extends StatefulWidget {
  const MealEditSheet({
    super.key,
    required this.meal,
    required this.knownCustomTags,
    required this.onCustomTagAdded,
    required this.onSave,
  });

  final Meal meal;

  /// Every custom tag ever created across all meals, offered here as quick-add
  /// suggestions (see [MealListController.knownCustomTags]).
  final Set<String> knownCustomTags;
  final ValueChanged<String> onCustomTagAdded;

  final void Function({
    required List<Ingredient> ingredients,
    required String instructions,
    int? cookTimeMinutes,
    required Set<MealTag> tags,
    required Set<String> customTags,
    required int servings,
  }) onSave;

  @override
  State<MealEditSheet> createState() => _MealEditSheetState();
}

/// One ingredient row's text controllers, split so the quantity can be scaled
/// independently of the unit and name elsewhere in the app.
class _IngredientRow {
  _IngredientRow({double? quantity, String unit = '', String name = ''})
      : quantity = TextEditingController(text: quantity == null ? '' : _trimTrailingZero(quantity)),
        unit = TextEditingController(text: unit),
        name = TextEditingController(text: name);

  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController name;

  static String _trimTrailingZero(double value) {
    final text = value.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  void dispose() {
    quantity.dispose();
    unit.dispose();
    name.dispose();
  }
}

class _MealEditSheetState extends State<MealEditSheet> {
  /// Common units offered in the ingredient unit field's dropdown - the field
  /// still accepts any free-text unit typed in that isn't on this list.
  static const _unitOptions = ['g', 'hg', 'kg', 'dl', 'cl', 'ml', 'l', 'msk', 'tsk', 'st', 'krm'];

  late final List<_IngredientRow> _ingredientRows;
  late final TextEditingController _instructionsController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;
  final _customTagController = TextEditingController();
  late Set<MealTag> _selectedTags;
  late Set<String> _selectedCustomTags;
  late final Set<String> _availableCustomTags;
  bool _tagsExpanded = false;

  @override
  void initState() {
    super.initState();
    final ingredients = widget.meal.ingredients;
    _ingredientRows = ingredients.isEmpty
        ? [_IngredientRow()]
        : [for (final ingredient in ingredients) _IngredientRow(quantity: ingredient.quantity, unit: ingredient.unit, name: ingredient.name)];
    _instructionsController = TextEditingController(text: widget.meal.instructions);
    _cookTimeController = TextEditingController(text: widget.meal.cookTimeMinutes?.toString() ?? '');
    _servingsController = TextEditingController(text: '${widget.meal.servings}');
    _selectedTags = Set.of(widget.meal.tags);
    _selectedCustomTags = Set.of(widget.meal.customTags);
    _availableCustomTags = {...widget.knownCustomTags, ...widget.meal.customTags};
  }

  @override
  void dispose() {
    for (final row in _ingredientRows) {
      row.dispose();
    }
    _instructionsController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _addIngredientField() => setState(() => _ingredientRows.add(_IngredientRow()));

  void _removeIngredientField(int index) => setState(() => _ingredientRows.removeAt(index).dispose());

  void _toggleTag(MealTag tag) => setState(() {
        if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
      });

  void _addCustomTag([String? tag]) {
    final newTag = (tag ?? _customTagController.text).trim();
    if (newTag.isEmpty) return;
    if (_selectedCustomTags.any((existing) => existing.toLowerCase() == newTag.toLowerCase())) return;
    final knownTag = _availableCustomTags.firstWhere(
      (existing) => existing.toLowerCase() == newTag.toLowerCase(),
      orElse: () => newTag,
    );
    setState(() {
      _availableCustomTags.add(knownTag);
      _selectedCustomTags.add(knownTag);
      _tagsExpanded = true;
      _customTagController.clear();
    });
    widget.onCustomTagAdded(knownTag);
  }

  void _removeCustomTag(String tag) => setState(() => _selectedCustomTags.remove(tag));

  List<String> _sortedTags(Iterable<String> tags) => tags.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  /// Collapsing keeps selected tags visible; expanding offers the full vocabulary.
  List<Widget> _buildTagChips(BuildContext context) {
    final selectedCustom = _sortedTags(_selectedCustomTags);
    final unselectedCustom = _sortedTags(
      _availableCustomTags.where((tag) => !_selectedCustomTags.any((selected) => selected.toLowerCase() == tag.toLowerCase())),
    );

    return [
      for (final tag in MealTag.values.where((tag) => _tagsExpanded || _selectedTags.contains(tag)))
        FilterChip(
          key: Key('tag-${tag.name}'),
          label: Text(tag.label),
          selected: _selectedTags.contains(tag),
          onSelected: (_) => _toggleTag(tag),
        ),
      for (final tag in selectedCustom)
        FilterChip(
          key: Key('custom-tag-chip-$tag'),
          label: Text(tag),
          selected: true,
          onSelected: (_) => _removeCustomTag(tag),
        ),
      for (final tag in _tagsExpanded ? unselectedCustom : const <String>[])
        FilterChip(
          key: Key('custom-tag-suggestion-$tag'),
          label: Text(tag),
          selected: false,
          onSelected: (_) => _addCustomTag(tag),
        ),
    ];
  }

  void _save() {
    final ingredients = [
      for (final row in _ingredientRows)
        if (row.name.text.trim().isNotEmpty)
          Ingredient(
            quantity: QuantityFormat.parse(row.quantity.text),
            unit: row.unit.text.trim(),
            name: row.name.text.trim(),
          ),
    ];
    final servings = int.tryParse(_servingsController.text.trim()) ?? Meal.defaultServings;
    widget.onSave(
      ingredients: ingredients,
      instructions: _instructionsController.text.trim(),
      cookTimeMinutes: int.tryParse(_cookTimeController.text.trim()),
      tags: _selectedTags,
      customTags: _selectedCustomTags,
      servings: servings < 1 ? 1 : servings,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.of(context).ink;
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.meal.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('cook-time-input'),
                    controller: _cookTimeController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Time to cook (minutes)', border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: const Key('servings-input'),
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Servings', border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              key: const Key('meal-tags-toggle'),
              onPressed: () => setState(() => _tagsExpanded = !_tagsExpanded),
              icon: Icon(_tagsExpanded ? Icons.expand_less : Icons.expand_more),
              label: Text(tr(context, _tagsExpanded ? 'tags.collapse' : 'tags.expand')),
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _buildTagChips(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('custom-tag-input'),
                    controller: _customTagController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: tr(context, 'meal.addCustomTagHint'),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                    onSubmitted: _addCustomTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(key: const Key('add-custom-tag-button'), icon: const Icon(Icons.add), onPressed: () => _addCustomTag()),
              ],
            ),
            const SizedBox(height: 16),
            Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 4),
            Text(
              'Quantities scale with servings in cooking mode. Enter a decimal (0.5) or a fraction (1/2) - leave the amount blank for things like "salt to taste". Pick a unit from the list or type your own.',
              style: TextStyle(color: AppColors.of(context).muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _ingredientRows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: TextField(
                        key: Key('ingredient-quantity-$i'),
                        controller: _ingredientRows[i].quantity,
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(isDense: true, hintText: '1 or 1/2', border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: DropdownMenu<String>(
                        key: Key('ingredient-unit-$i'),
                        controller: _ingredientRows[i].unit,
                        width: 110,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        hintText: 'Unit',
                        inputDecorationTheme:
                            const InputDecorationTheme(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
                        dropdownMenuEntries: [for (final unit in _unitOptions) DropdownMenuEntry(value: unit, label: unit)],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        key: Key('ingredient-input-$i'),
                        controller: _ingredientRows[i].name,
                        decoration:
                            const InputDecoration(isDense: true, hintText: 'Ingredient', border: OutlineInputBorder(borderRadius: BorderRadius.zero)),
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
            Text('Instructions', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
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
