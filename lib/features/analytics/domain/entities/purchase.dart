/// Entity representing a purchase record for spending analytics.
class Purchase {
  final String id;
  final String itemName;
  final double price;
  final int quantity;
  final String? category;
  final DateTime purchaseDate;
  final String? storeName;

  const Purchase({
    required this.id,
    required this.itemName,
    required this.price,
    required this.quantity,
    this.category,
    required this.purchaseDate,
    this.storeName,
  });

  double get totalPrice => price * quantity;

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
