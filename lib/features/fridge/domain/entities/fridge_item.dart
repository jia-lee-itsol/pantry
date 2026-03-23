/// Represents a food item stored in the fridge.
///
/// A fridge item tracks information about food products including:
/// - Basic details (name, quantity, category)
/// - Expiration tracking for food safety
/// - Storage location (regular fridge vs freezer)
/// - Low stock alerts via target quantity
///
/// ## Business Rules:
/// - Items can be categorized for better organization
/// - Frozen items have different expiration considerations
/// - Target quantity enables stock replenishment notifications
///
/// ## Example:
/// ```dart
/// final milk = FridgeItem(
///   id: 'item123',
///   name: 'Milk',
///   quantity: 2,
///   category: 'Dairy',
///   expiryDate: DateTime.now().add(Duration(days: 7)),
///   createdAt: DateTime.now(),
///   isFrozen: false,
///   targetQuantity: 1, // Alert when quantity drops to 1 or below
/// );
/// ```
class FridgeItem {
  /// Unique identifier for the fridge item
  final String id;

  /// Display name of the food item (e.g., "Milk", "Apple")
  final String name;

  /// Current quantity/count of the item
  final int quantity;

  /// Category for organization (e.g., "Dairy", "Vegetables", "Meat")
  ///
  /// Nullable to support uncategorized items.
  final String? category;

  /// Expiration date of the item for food safety tracking
  final DateTime expiryDate;

  /// Timestamp when the item was created
  final DateTime createdAt;

  /// Timestamp when the item was last updated
  ///
  /// Nullable as items may never be updated after creation.
  final DateTime? updatedAt;

  /// Whether the item is stored in the freezer
  ///
  /// Frozen items may have different expiration considerations.
  /// Defaults to `false`.
  final bool isFrozen;

  /// Target quantity threshold for low stock notifications
  ///
  /// When the item's quantity drops to or below this value,
  /// the system can trigger replenishment alerts.
  /// Nullable as not all items need stock alerts.
  final int? targetQuantity;

  const FridgeItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.category,
    required this.expiryDate,
    required this.createdAt,
    this.updatedAt,
    this.isFrozen = false,
    this.targetQuantity,
  });

  /// Creates a copy of this item with optional field updates.
  ///
  /// Any field not provided will retain its current value.
  ///
  /// Example:
  /// ```dart
  /// final updatedMilk = milk.copyWith(quantity: 1);
  /// ```
  FridgeItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFrozen,
    int? targetQuantity,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFrozen: isFrozen ?? this.isFrozen,
      targetQuantity: targetQuantity ?? this.targetQuantity,
    );
  }
}
