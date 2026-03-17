import '../../domain/entities/purchase.dart';

class PurchaseModel extends Purchase {
  const PurchaseModel({
    required super.id,
    required super.itemName,
    required super.price,
    required super.quantity,
    super.category,
    required super.purchaseDate,
    super.storeName,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['id'] as String,
      itemName: json['itemName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      category: json['category'] as String?,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      storeName: json['storeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'price': price,
      'quantity': quantity,
      'category': category,
      'purchaseDate': purchaseDate.toIso8601String(),
      'storeName': storeName,
    };
  }

  factory PurchaseModel.fromEntity(Purchase purchase) {
    return PurchaseModel(
      id: purchase.id,
      itemName: purchase.itemName,
      price: purchase.price,
      quantity: purchase.quantity,
      category: purchase.category,
      purchaseDate: purchase.purchaseDate,
      storeName: purchase.storeName,
    );
  }
}
