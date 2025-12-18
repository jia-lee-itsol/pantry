import '../../domain/entities/receipt_item.dart';

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.quantity,
    required super.purchaseDate,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }
}

