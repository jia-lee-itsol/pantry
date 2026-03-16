/// Use Case for determining if an item is low on stock.
/// Contains business rule: item is low if quantity < targetQuantity (or default threshold).
class CheckLowStockUseCase {
  static const int defaultThreshold = 5;

  /// Check if an item is low on stock based on quantity and target.
  bool call({
    required int quantity,
    int? targetQuantity,
  }) {
    final threshold = targetQuantity ?? defaultThreshold;
    return quantity < threshold;
  }

  /// Filter items that are low on stock.
  /// [items] is a list of items with quantity and optional targetQuantity.
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
