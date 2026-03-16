import '../entities/stock_item.dart';
import 'guess_category_usecase.dart';

/// Use Case for grouping stock items by category and sorting them.
class GroupStockItemsUseCase {
  final GuessCategoryUseCase _guessCategoryUseCase;

  GroupStockItemsUseCase(this._guessCategoryUseCase);

  Map<String, List<StockItem>> call(List<StockItem> items) {
    final Map<String, List<StockItem>> grouped = {};

    for (final item in items) {
      final category = item.category ?? _guessCategoryUseCase(item.name);
      grouped.putIfAbsent(category, () => []).add(item);
    }

    // Sort items within each category by expiry date (longest first)
    // Items without expiry date go to the bottom
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return b.expiryDate!.compareTo(a.expiryDate!);
      });
    }

    // Sort categories by predefined order
    final sortedGrouped = <String, List<StockItem>>{};

    for (final category in GuessCategoryUseCase.categoryOrder) {
      if (grouped.containsKey(category)) {
        sortedGrouped[category] = grouped[category]!;
      }
    }

    // Add remaining categories not in predefined order
    for (final entry in grouped.entries) {
      if (!GuessCategoryUseCase.categoryOrder.contains(entry.key)) {
        sortedGrouped[entry.key] = entry.value;
      }
    }

    return sortedGrouped;
  }
}
