class StockItem {
  final String id;
  final String name;
  final int quantity;
  final DateTime lastUpdated;
  final String? category;
  final DateTime? expiryDate;
  final int? targetQuantity; // 목표 수량 (알림 기준)

  const StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.lastUpdated,
    this.category,
    this.expiryDate,
    this.targetQuantity,
  });

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
