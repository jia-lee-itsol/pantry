import '../entities/fridge_item.dart';

/// Sort filter options for fridge items.
/// This enum is defined in domain layer and should be used by presentation.
enum SortFilter {
  expiryDateAsc,
  quantityAsc,
}

/// Use Case for grouping fridge items by category and sorting them.
class GroupFridgeItemsUseCase {
  Map<String, List<FridgeItem>> call(
    List<FridgeItem> items, {
    SortFilter sortFilter = SortFilter.expiryDateAsc,
  }) {
    final Map<String, List<FridgeItem>> grouped = {};

    for (final item in items) {
      final category = item.category ?? 'その他';
      grouped.putIfAbsent(category, () => []).add(item);
    }

    // Sort items within each category
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) {
        switch (sortFilter) {
          case SortFilter.expiryDateAsc:
            return a.expiryDate.compareTo(b.expiryDate);
          case SortFilter.quantityAsc:
            return a.quantity.compareTo(b.quantity);
        }
      });
    }

    return grouped;
  }

  /// Sort categories with 'その他' always at the end.
  List<String> sortCategories(List<String> categories) {
    return categories.toList()
      ..sort((a, b) {
        if (a == 'その他') return 1;
        if (b == 'その他') return -1;
        return a.compareTo(b);
      });
  }
}
