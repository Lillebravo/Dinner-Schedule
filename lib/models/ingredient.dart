/// A single ingredient line on a [Meal]'s recipe: an optional exact amount
/// (so it can be scaled for a different serving size) plus the ingredient's
/// name, e.g. `Ingredient(quantity: 2, unit: 'cups', name: 'flour')`.
/// [quantity] is left null for amounts that don't scale meaningfully (e.g.
/// "salt to taste"), in which case [name] is shown as-is at any serving size.
class Ingredient {
  Ingredient({this.quantity, this.unit = '', required String name}) : name = name.trim();

  final double? quantity;
  final String unit;
  final String name;

  /// This ingredient scaled by [factor] (e.g. 1.5 for 1.5x the recipe).
  /// Ingredients with no [quantity] are returned unchanged, since there's
  /// nothing to scale.
  Ingredient scaled(double factor) {
    if (quantity == null) return this;
    return Ingredient(quantity: quantity! * factor, unit: unit, name: name);
  }

  @override
  bool operator ==(Object other) =>
      other is Ingredient && other.quantity == quantity && other.unit == unit && other.name == name;

  @override
  int get hashCode => Object.hash(quantity, unit, name);

  @override
  String toString() => quantity == null ? name : '$quantity${unit.isEmpty ? '' : ' $unit'} $name';
}
