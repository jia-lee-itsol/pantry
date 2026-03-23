import '../../domain/entities/stock_item.dart';

// ============================================
// Stock Item Model
// ============================================

/// Data transfer object (DTO) for stock items.
///
/// This model extends the domain [StockItem] entity and adds serialization
/// capabilities for data persistence. It serves as the bridge between the
/// domain layer and the data layer.
///
/// **Key Responsibilities:**
/// - JSON serialization/deserialization
/// - Data validation during parsing
/// - Type-safe data conversion
/// - Compatibility with various data sources (Firestore, local DB, APIs)
///
/// **Design Pattern:**
/// Extends [StockItem] to maintain type compatibility while adding
/// data layer functionality. This allows models to be used wherever
/// entities are expected.
class StockItemModel extends StockItem {
  /// Creates a new [StockItemModel] instance.
  ///
  /// All parameters are passed to the parent [StockItem] constructor.
  const StockItemModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.lastUpdated,
    super.category,
    super.expiryDate,
    super.targetQuantity,
  });

  /// Creates a [StockItemModel] from a JSON map.
  ///
  /// This factory constructor is used for deserializing data from
  /// storage sources like Firestore, local databases, or API responses.
  ///
  /// **Required JSON fields:**
  /// - `id` (String): Unique identifier
  /// - `name` (String): Item name
  /// - `quantity` (int): Current quantity
  /// - `lastUpdated` (String): ISO 8601 timestamp
  ///
  /// **Optional JSON fields:**
  /// - `category` (String): Item category
  /// - `expiryDate` (String): ISO 8601 timestamp
  /// - `targetQuantity` (int): Target quantity threshold
  ///
  /// Parameters:
  /// - [json]: The JSON map to parse
  ///
  /// Returns a new [StockItemModel] instance.
  ///
  /// Throws [FormatException] if required fields are missing or date parsing fails.
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

  /// Converts this [StockItemModel] to a JSON map.
  ///
  /// This method is used for serializing the model before persisting
  /// to storage sources like Firestore or local databases.
  ///
  /// **JSON Structure:**
  /// - All required fields are always included
  /// - Optional fields are only included if they have values
  /// - `targetQuantity` is included even if null (enables Firestore field deletion)
  /// - Dates are formatted as ISO 8601 strings
  ///
  /// Returns a JSON-serializable map representation of this model.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toIso8601String(),
      if (category != null) 'category': category,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      // targetQuantity is included even if null (for Firestore field deletion)
      'targetQuantity': targetQuantity,
    };
  }
}
