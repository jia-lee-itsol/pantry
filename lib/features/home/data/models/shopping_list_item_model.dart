import '../../domain/entities/shopping_list_item.dart';

// ============================================
// Shopping List Item Model
// ============================================

/// Data model for shopping list items with JSON serialization support.
///
/// This model extends [ShoppingListItem] entity and adds serialization
/// capabilities for data persistence and transfer. It serves as a bridge
/// between the domain layer and data sources.
///
/// The model handles conversion between:
/// - Domain entities (for business logic)
/// - JSON format (for storage/network)
class ShoppingListItemModel extends ShoppingListItem {
  /// Creates a [ShoppingListItemModel] instance.
  ///
  /// Parameters match those of [ShoppingListItem]:
  /// - [id]: Unique identifier (required)
  /// - [name]: Item name (required)
  /// - [estimatedPrice]: Optional estimated price
  /// - [isCompleted]: Completion status (defaults to false)
  /// - [category]: Item category - 'fridge' or 'stock' (required)
  const ShoppingListItemModel({
    required super.id,
    required super.name,
    super.estimatedPrice,
    super.isCompleted = false,
    required super.category,
  });

  /// Creates a [ShoppingListItemModel] from a JSON map.
  ///
  /// This factory is used when deserializing data from storage or network.
  ///
  /// Parameters:
  /// - [json]: Map containing the item data
  ///
  /// Returns a new [ShoppingListItemModel] instance with data from the JSON.
  ///
  /// Example:
  /// ```dart
  /// final model = ShoppingListItemModel.fromJson({
  ///   'id': '123',
  ///   'name': 'Milk',
  ///   'category': 'fridge',
  /// });
  /// ```
  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      estimatedPrice: json['estimatedPrice'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      category: json['category'] as String,
    );
  }

  /// Converts this model to a JSON map.
  ///
  /// This method is used when serializing data for storage or network transfer.
  ///
  /// Returns a Map containing all item properties in JSON-compatible format.
  ///
  /// Example:
  /// ```dart
  /// final json = model.toJson();
  /// // {'id': '123', 'name': 'Milk', ...}
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'estimatedPrice': estimatedPrice,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  /// Creates a [ShoppingListItemModel] from a domain entity.
  ///
  /// This factory is used when converting domain entities to data models
  /// for persistence operations.
  ///
  /// Parameters:
  /// - [item]: The [ShoppingListItem] entity to convert
  ///
  /// Returns a new [ShoppingListItemModel] with the same data as the entity.
  ///
  /// Example:
  /// ```dart
  /// final model = ShoppingListItemModel.fromEntity(entity);
  /// ```
  factory ShoppingListItemModel.fromEntity(ShoppingListItem item) {
    return ShoppingListItemModel(
      id: item.id,
      name: item.name,
      estimatedPrice: item.estimatedPrice,
      isCompleted: item.isCompleted,
      category: item.category,
    );
  }

  /// Converts this model to a domain entity.
  ///
  /// This method is used when converting data models to domain entities
  /// for use in business logic.
  ///
  /// Returns a new [ShoppingListItem] entity with the same data as this model.
  ///
  /// Example:
  /// ```dart
  /// final entity = model.toEntity();
  /// ```
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

