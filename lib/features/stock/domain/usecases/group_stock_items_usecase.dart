import '../entities/stock_item.dart';
import 'guess_category_usecase.dart';

// ============================================
// Group Stock Items Use Case
// ============================================

/// Use case for organizing stock items by category with intelligent sorting.
///
/// This use case provides advanced grouping and sorting functionality:
/// 1. Groups items by category (uses auto-detection if category is not set)
/// 2. Sorts items within each category by expiration date
/// 3. Orders categories according to predefined priority
///
/// The sorting strategy ensures:
/// - Categories appear in a logical, user-friendly order
/// - Items with earlier expiration dates appear first within their category
/// - Items without expiration dates appear last within their category
///
/// Usage:
/// ```dart
/// final useCase = GroupStockItemsUseCase(guessCategoryUseCase);
/// final grouped = useCase(allItems);
/// // Returns: Map<String, List<StockItem>>
/// ```
class GroupStockItemsUseCase {
  /// The use case instance for category detection
  final GuessCategoryUseCase _guessCategoryUseCase;

  /// Creates a new instance of [GroupStockItemsUseCase].
  ///
  /// Parameters:
  /// - [_guessCategoryUseCase]: The use case for guessing categories from item names
  GroupStockItemsUseCase(this._guessCategoryUseCase);

  /// Executes the use case to group and sort stock items.
  ///
  /// Parameters:
  /// - [items]: The list of stock items to group and sort
  ///
  /// Returns a map where:
  /// - Keys are category names
  /// - Values are lists of items in that category, sorted by expiration date
  ///
  /// The returned map is ordered according to [GuessCategoryUseCase.categoryOrder].
  Map<String, List<StockItem>> call(List<StockItem> items) {
    final Map<String, List<StockItem>> grouped = {};

    // Group items by category
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

    // Add categories in predefined order
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
