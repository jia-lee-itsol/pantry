import '../../domain/entities/stock_item.dart';

class StockItemModel extends StockItem {
  const StockItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.lastUpdated,
    super.category,
    super.expiryDate,
    super.targetQuantity,
  });

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      category: json['category'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      targetQuantity: json['targetQuantity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toIso8601String(),
      if (category != null) 'category': category,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      // targetQuantity는 null이어도 포함 (Firestore에서 필드 삭제를 위해)
      'targetQuantity': targetQuantity,
    };
  }
}
