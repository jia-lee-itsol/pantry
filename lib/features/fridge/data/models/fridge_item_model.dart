import '../../domain/entities/fridge_item.dart';

class FridgeItemModel extends FridgeItem {
  const FridgeItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    super.category,
    required super.expiryDate,
    required super.createdAt,
    super.updatedAt,
    super.isFrozen = false,
    super.targetQuantity,
  });

  factory FridgeItemModel.fromJson(Map<String, dynamic> json) {
    return FridgeItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      category: json['category'] as String?,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isFrozen: json['isFrozen'] as bool? ?? false,
      targetQuantity: json['targetQuantity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isFrozen': isFrozen,
    };
    
    if (category != null) {
      json['category'] = category;
    }
    
    if (updatedAt != null) {
      json['updatedAt'] = updatedAt!.toIso8601String();
    }
    
    // targetQuantity는 null이어도 포함 (Firestore에서 필드 삭제를 위해)
    json['targetQuantity'] = targetQuantity;
    
    return json;
  }
}
