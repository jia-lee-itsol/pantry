class FridgeItem {
  final String id;
  final String name;
  final int quantity;
  final String? category;
  final DateTime expiryDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFrozen;
  final int? targetQuantity; // 목표 수량 (알림 기준)

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
