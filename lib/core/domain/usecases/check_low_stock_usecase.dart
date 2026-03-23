/// Check Low Stock Use Case
///
/// Business logic for determining if an item is low on stock.
/// This use case encapsulates the core business rule: an item is considered
/// low on stock if its quantity is less than the target quantity.
///
/// Business Rules:
/// - If targetQuantity is specified: Low when quantity < targetQuantity
/// - If targetQuantity is null: Low when quantity < defaultThreshold (5)
///
/// This use case is stateless and can be reused across the application.
class CheckLowStockUseCase {
  /// Default stock threshold when no target quantity is specified
  static const int defaultThreshold = 5;

  /// Checks if an item is low on stock
  ///
  /// Parameters:
  ///   - quantity: Current quantity of the item
  ///   - targetQuantity: Optional target quantity threshold
  ///
  /// Returns: `true` if the item is low on stock, `false` otherwise
  bool call({
    required int quantity,
    int? targetQuantity,
  }) {
    final threshold = targetQuantity ?? defaultThreshold;
    return quantity < threshold;
  }

  /// Filters a list of items to return only those low on stock
  ///
  /// This is a generic method that works with any item type by using
  /// accessor functions to retrieve quantity and target quantity.
  ///
  /// Parameters:
  ///   - items: List of items to filter
  ///   - getQuantity: Function to extract quantity from an item
  ///   - getTargetQuantity: Function to extract target quantity from an item
  ///
  /// Returns: List of items that are low on stock
  ///
  /// Example:
  /// ```dart
  /// final lowStockItems = useCase.filterLowStock(
  ///   items: stockItems,
  ///   getQuantity: (item) => item.quantity,
  ///   getTargetQuantity: (item) => item.targetQuantity,
  /// );
  /// ```
  List<T> filterLowStock<T>({
    required List<T> items,
    required int Function(T) getQuantity,
    required int? Function(T) getTargetQuantity,
  }) {
    return items.where((item) {
      return call(
        quantity: getQuantity(item),
        targetQuantity: getTargetQuantity(item),
      );
    }).toList();
  }
}
