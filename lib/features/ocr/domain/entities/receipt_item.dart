/// Domain entity representing an item extracted from a scanned receipt.
///
/// This entity encapsulates product information parsed from receipt images
/// using OCR technology. Each item includes details about the product,
/// its price, quantity, and purchase date.
class ReceiptItem {
  /// Unique identifier for the receipt item
  final String id;

  /// Name of the product as extracted from the receipt
  final String name;

  /// Price of the product
  final double price;

  /// Quantity of the product purchased
  final int quantity;

  /// Date when the product was purchased
  final DateTime purchaseDate;

  /// Creates a [ReceiptItem] instance.
  ///
  /// All parameters are required to ensure complete product information.
  const ReceiptItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.purchaseDate,
  });
}

