/// Domain entity representing a purchase record for spending analytics.
///
/// This entity captures information about purchased items including price,
/// quantity, category, and purchase date for tracking spending patterns.
class Purchase {
  /// Unique identifier for the purchase record
  final String id;

  /// Name of the purchased item
  final String itemName;

  /// Unit price of the item
  final double price;

  /// Quantity of items purchased
  final int quantity;

  /// Category of the purchased item
  final String? category;

  /// Date and time when the purchase was made
  final DateTime purchaseDate;

  /// Name of the store where the item was purchased
  final String? storeName;

  /// Creates a [Purchase] instance.
  ///
  /// Required parameters: [id], [itemName], [price], [quantity], and [purchaseDate].
  /// [category] and [storeName] are optional.
  const Purchase({
    required this.id,
    required this.itemName,
    required this.price,
    required this.quantity,
    this.category,
    required this.purchaseDate,
    this.storeName,
  });

  /// Calculates the total price for this purchase.
  ///
  /// Returns the product of unit price and quantity.
  double get totalPrice => price * quantity;

  /// Creates a copy of this purchase with the given fields replaced.
  ///
  /// Returns a new [Purchase] instance with updated values for any
  /// non-null parameters, keeping existing values for null parameters.
  Purchase copyWith({
    String? id,
    String? itemName,
    double? price,
    int? quantity,
    String? category,
    DateTime? purchaseDate,
    String? storeName,
  }) {
    return Purchase(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      storeName: storeName ?? this.storeName,
    );
  }
}
