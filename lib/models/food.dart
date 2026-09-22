/// A single entry on the dinner wheel.
class Food {
  Food(String name) : name = name.trim();

  final String name;

  /// Whether this entry's name matches [other], ignoring case and surrounding whitespace.
  bool matchesName(String other) => name.toLowerCase() == other.trim().toLowerCase();

  @override
  bool operator ==(Object other) => other is Food && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
