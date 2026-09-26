import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../../theme/app_theme.dart';

/// How the shopping list is currently ordered.
enum ShoppingSortOption { custom, nameAZ, nameZA, uncheckedFirst }

/// A sortable criterion in the UI. Each maps to a pair of [ShoppingSortOption]s
/// (ascending/descending) that a single button cycles through, except
/// [status] which only has one direction. Mirrors the home meals list's sort.
enum ShoppingSortCriterion { name, status }

/// Owns the shopping list's sort order - a page-local view preference, not
/// persisted list data - cycling ascending -> descending -> no sort (custom
/// order) per criterion, exactly like the home meals list's sort.
class ShoppingSortController extends ChangeNotifier {
  ShoppingSortOption _option = ShoppingSortOption.custom;

  ShoppingSortOption get option => _option;

  /// The sort criterion currently in effect, or null when unsorted (custom order).
  ShoppingSortCriterion? get activeCriterion => switch (_option) {
        ShoppingSortOption.nameAZ || ShoppingSortOption.nameZA => ShoppingSortCriterion.name,
        ShoppingSortOption.uncheckedFirst => ShoppingSortCriterion.status,
        ShoppingSortOption.custom => null,
      };

  bool get isDescending => _option == ShoppingSortOption.nameZA;

  /// Cycles [criterion] through ascending -> descending -> no sort (custom
  /// order). [ShoppingSortCriterion.status] only has one direction, so it just
  /// toggles on/off. Selecting a different criterion than the one currently
  /// active starts it fresh (ascending).
  void cycle(ShoppingSortCriterion criterion) {
    switch (criterion) {
      case ShoppingSortCriterion.name:
        _option = switch (_option) {
          ShoppingSortOption.nameAZ => ShoppingSortOption.nameZA,
          ShoppingSortOption.nameZA => ShoppingSortOption.custom,
          _ => ShoppingSortOption.nameAZ,
        };
      case ShoppingSortCriterion.status:
        _option = _option == ShoppingSortOption.uncheckedFirst ? ShoppingSortOption.custom : ShoppingSortOption.uncheckedFirst;
    }
    notifyListeners();
  }
}

/// A single icon button that opens a sheet of sort criteria. Tapping a
/// criterion cycles it through ascending -> descending -> no sort, mirroring
/// the home meals list's sort control.
class ShoppingSortControl extends StatelessWidget {
  const ShoppingSortControl({super.key, required this.controller});

  final ShoppingSortController controller;

  static const _labelKeys = {
    ShoppingSortCriterion.name: 'sort.name',
    ShoppingSortCriterion.status: 'shopping.sortUnchecked',
  };

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(tr(context, 'sort.title'), style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.of(context).ink, fontSize: 13)),
                ),
              ),
              for (final criterion in ShoppingSortCriterion.values)
                ListTile(
                  key: Key('shopping-sort-option-${criterion.name}'),
                  title: Text(tr(context, _labelKeys[criterion]!)),
                  trailing: controller.activeCriterion == criterion
                      ? Icon(controller.isDescending ? Icons.arrow_downward : Icons.arrow_upward, color: AppColors.of(context).coral)
                      : Icon(Icons.unfold_more, color: AppColors.of(context).muted),
                  selected: controller.activeCriterion == criterion,
                  onTap: () => controller.cycle(criterion),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = controller.activeCriterion != null;
    return IconButton(
      key: const Key('shopping-sort-button'),
      tooltip: tr(context, 'sort.tooltip'),
      onPressed: () => _openSheet(context),
      icon: Badge(isLabelVisible: active, smallSize: 8, child: const Icon(Icons.sort)),
    );
  }
}

