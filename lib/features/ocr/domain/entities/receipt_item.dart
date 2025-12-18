class ReceiptItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final DateTime purchaseDate;

  const ReceiptItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.purchaseDate,
  });
}

