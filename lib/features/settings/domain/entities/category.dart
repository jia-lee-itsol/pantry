/// Domain entity representing a product category.
///
/// Categories are used to organize and classify items in the pantry system.
/// Each category has a name, icon, and order for display purposes.
class Category {
  /// Unique identifier for the category
  final String id;

  /// Display name of the category
  final String name;

  /// Icon name stored as string (represents IconData)
  final String iconName;

  /// Display order for sorting categories
  final int order;

  /// Timestamp when the category was created
  final DateTime createdAt;

  /// Creates a [Category] instance.
  ///
  /// All parameters are required except [order] which defaults to 0.
  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    this.order = 0,
    required this.createdAt,
  });

  /// Creates a copy of this category with the given fields replaced.
  ///
  /// Returns a new [Category] instance with updated values for any
  /// non-null parameters, keeping existing values for null parameters.
  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? order,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
