/// One entry on a week's shopping list: either an ingredient consolidated from
/// that week's home-cooked dinners, or a free-form item added by hand.
class ShoppingListItem {
  const ShoppingListItem({
    required this.name,
    required this.count,
    required this.mealNames,
    this.manualId,
    this.totalQuantity,
    this.unit = '',
  });

  /// The ingredient text as originally entered on a meal's recipe, or the raw
  /// text typed in for a manually-added item.
  final String name;

  /// How many scheduled dinners this week call for this ingredient. Always 1
  /// for a manually-added item.
  final int count;

  /// Names of the meals (in schedule order) that need this ingredient, may
  /// repeat if the same meal is scheduled more than once in the week. Empty
  /// for a manually-added item.
  final List<String> mealNames;

  /// Set only when this item was added by hand rather than derived from the
  /// schedule; identifies it for removal/checked-state independent of its text.
  final String? manualId;

  /// The exact total amount needed across every contributing recipe this week
  /// (e.g. 2 onions + 3 onions = 5), or null when there's nothing to total -
  /// no recipe gave this ingredient an exact quantity, or the quantities that
  /// were given don't share a common [unit] to add together.
  final double? totalQuantity;

  /// The shared unit [totalQuantity] is measured in (e.g. "cups"), or empty
  /// when the ingredient is just counted (e.g. "2 onions").
  final String unit;

  bool get isManual => manualId != null;

  /// A stable identity for checked-state/removal: the manual id if hand-added,
  /// otherwise a case/whitespace-insensitive key so "Onion" and "onion " merge.
  String get key => manualId ?? name.trim().toLowerCase();
}
