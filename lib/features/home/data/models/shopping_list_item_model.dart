import '../../domain/entities/shopping_list_item.dart';

class ShoppingListItemModel extends ShoppingListItem {
  const ShoppingListItemModel({
    required super.id,
    required super.name,
    super.estimatedPrice,
    super.isCompleted = false,
    required super.category,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      estimatedPrice: json['estimatedPrice'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimatedPrice': estimatedPrice,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  factory ShoppingListItemModel.fromEntity(ShoppingListItem item) {
    return ShoppingListItemModel(
      id: item.id,
      name: item.name,
      estimatedPrice: item.estimatedPrice,
      isCompleted: item.isCompleted,
      category: item.category,
    );
  }

  ShoppingListItem toEntity() {
    return ShoppingListItem(
      id: id,
      name: name,
      estimatedPrice: estimatedPrice,
      isCompleted: isCompleted,
      category: category,
    );
  }
}

