import 'package:flutter/material.dart';

import '../../controllers/meal_list_controller.dart';
import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';

const _filterLabelKeys = {
  MealFilter.quick: 'filter.quick',
  MealFilter.vegetarian: 'filter.vegetarian',
  MealFilter.vegan: 'filter.vegan',
  MealFilter.pescatarian: 'filter.pescatarian',
  MealFilter.glutenFree: 'filter.glutenFree',
  MealFilter.comfortFood: 'filter.comfortFood',
  MealFilter.pantryFriendly: 'filter.pantryFriendly',
};

List<String> _sortedTags(Iterable<String> tags) => tags.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

/// A single icon button that opens a sheet of smart filters (Quick, Vegetarian,
/// Vegan, Pescatarian, Gluten-Free, Comfort Food, Pantry Friendly, and any
/// custom tags the user has created) - all in one unified list.
class MealFilterControl extends StatelessWidget {
  const MealFilterControl({super.key, required this.controller});

  final MealListController controller;

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.hasActiveFilters;
    return IconButton(
      key: const Key('filter-menu-button'),
      tooltip: tr(context, 'filter.tooltip'),
      onPressed: () => _openSheet(context),
      icon: Badge(
        isLabelVisible: active,
        label: Text('${controller.activeFilters.length + controller.activeCustomTagFilters.length}'),
        child: const Icon(Icons.filter_alt_outlined),
      ),
    );
  }
}

/// The full filter vocabulary can be expanded; active filters stay visible
/// when collapsed.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.controller});

  final MealListController controller;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  bool _tagsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final colors = AppColors.of(context);
        final selectedCustom = _sortedTags(widget.controller.activeCustomTagFilters);
        final unselectedCustom = _sortedTags(
          widget.controller.knownCustomTags.where((tag) => !widget.controller.activeCustomTagFilters.any((s) => s.toLowerCase() == tag.toLowerCase())),
        );

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(tr(context, 'filter.title'), style: TextStyle(fontWeight: FontWeight.w800, color: colors.ink, fontSize: 13)),
                    ),
                  ),
                  ListTile(
                    key: const Key('filter-tags-toggle'),
                    title: Text(tr(context, _tagsExpanded ? 'tags.collapse' : 'tags.expand')),
                    trailing: Icon(_tagsExpanded ? Icons.expand_less : Icons.expand_more),
                    onTap: () => setState(() => _tagsExpanded = !_tagsExpanded),
                  ),
                  for (final filter in MealFilter.values.where((filter) => _tagsExpanded || widget.controller.activeFilters.contains(filter)))
                    CheckboxListTile(
                      key: Key('filter-${filter.name}'),
                      title: Text(tr(context, _filterLabelKeys[filter]!)),
                      value: widget.controller.activeFilters.contains(filter),
                      onChanged: (_) => widget.controller.toggleFilter(filter),
                    ),
                  for (final tag in selectedCustom)
                    CheckboxListTile(
                      key: Key('filter-custom-$tag'),
                      title: Text(tag),
                      value: true,
                      onChanged: (_) => widget.controller.toggleCustomTagFilter(tag),
                    ),
                  for (final tag in _tagsExpanded ? unselectedCustom : const <String>[])
                    CheckboxListTile(
                      key: Key('filter-custom-$tag'),
                      title: Text(tag),
                      value: false,
                      onChanged: (_) => widget.controller.toggleCustomTagFilter(tag),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
