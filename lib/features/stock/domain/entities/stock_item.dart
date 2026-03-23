// ============================================
// Stock Item Entity
// ============================================

/// Domain entity representing a stock item in the pantry inventory system.
///
/// This is a core business entity that represents an item stored in the pantry.
/// It contains all the essential information needed to track inventory levels,
/// expiration dates, and categorization.
///
/// This entity follows clean architecture principles and should not contain
/// any framework-specific or data layer implementation details.
class StockItem {
  /// Unique identifier for the stock item
  final String id;

  /// Name of the stock item (e.g., "Rice", "Water bottles")
  final String name;

  /// Current quantity of the item in stock
  final int quantity;

  /// Timestamp of the last update to this item
  final DateTime lastUpdated;

  /// Optional category for organizing items (e.g., "Beverages", "Grains")
  final String? category;

  /// Optional expiration date for perishable items
  final DateTime? expiryDate;

  /// Optional target quantity for notification threshold
  /// When current quantity falls below this value, notifications can be triggered
  final int? targetQuantity;

  /// Creates a new [StockItem] instance.
  ///
  /// All parameters except [category], [expiryDate], and [targetQuantity] are required.
  const StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.lastUpdated,
    this.category,
    this.expiryDate,
    this.targetQuantity,
  });

  /// Creates a copy of this [StockItem] with the given fields replaced with new values.
  ///
  /// This is useful for creating modified versions of an existing stock item
  /// while maintaining immutability.
  ///
  /// Returns a new [StockItem] instance with updated values.
  StockItem copyWith({
    String? id,
    String? name,
    int? quantity,
    DateTime? lastUpdated,
    String? category,
    DateTime? expiryDate,
    int? targetQuantity,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      targetQuantity: targetQuantity ?? this.targetQuantity,
    );
  }
}
