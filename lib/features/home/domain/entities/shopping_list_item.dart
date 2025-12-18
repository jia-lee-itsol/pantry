class ShoppingListItem {
  final String id;
  final String name;
  final int? estimatedPrice; // 예상 가격 (옵션)
  final bool isCompleted;
  final String category; // 'fridge' 또는 'stock'

  const ShoppingListItem({
    required this.id,
    required this.name,
    this.estimatedPrice,
    this.isCompleted = false,
    required this.category,
  });

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
