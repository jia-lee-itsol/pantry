// ============================================
// Shopping List Item Entity
// ============================================

/// Represents an item in the shopping list.
///
/// This entity is used to track items that need to be purchased,
/// including their completion status and category (fridge or stock items).
/// Each item can have an optional estimated price for budgeting purposes.
class ShoppingListItem {
  /// Unique identifier for the shopping list item
  final String id;

  /// Name of the item to purchase
  final String name;

  /// Estimated price in the local currency (optional)
  final int? estimatedPrice;

  /// Whether the item has been purchased or completed
  final bool isCompleted;

  /// Category of the item: 'fridge' for refrigerator items or 'stock' for stockpile items
  final String category;

  /// Creates a [ShoppingListItem] instance.
  ///
  /// Parameters:
  /// - [id]: Unique identifier (required)
  /// - [name]: Item name (required)
  /// - [estimatedPrice]: Optional estimated price
  /// - [isCompleted]: Completion status (defaults to false)
  /// - [category]: Item category - 'fridge' or 'stock' (required)
  const ShoppingListItem({
    required this.id,
    required this.name,
    this.estimatedPrice,
    this.isCompleted = false,
    required this.category,
  });

  /// Creates a copy of this item with the specified properties replaced.
  ///
  /// Returns a new [ShoppingListItem] with the same values as this one,
  /// except for any properties that are explicitly provided.
  ///
  /// Example:
  /// ```dart
  /// final newItem = item.copyWith(isCompleted: true);
  /// ```
  ShoppingListItem copyWith({
    String? id,
    String? name,
    int? estimatedPrice,
    bool? isCompleted,
    String? category,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }
}
