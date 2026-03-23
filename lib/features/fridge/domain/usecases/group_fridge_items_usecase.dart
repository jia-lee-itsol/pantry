import '../entities/fridge_item.dart';

/// Sort options for fridge items.
///
/// This enum is defined in the domain layer to ensure business logic
/// remains independent of presentation concerns.
enum SortFilter {
  /// Sort by expiration date (earliest first)
  expiryDateAsc,

  /// Sort by quantity (lowest first)
  quantityAsc,
}

/// Use case for grouping and sorting fridge items by category.
///
/// This use case organizes fridge items into categories for better
/// UI presentation and applies sorting within each category.
///
/// ## Business Rules:
/// - Uncategorized items go to "その他" (Other) category
/// - Items within each category are sorted by the specified filter
/// - "その他" category always appears last in the category list
///
/// ## Usage:
/// ```dart
/// final useCase = GroupFridgeItemsUseCase();
///
/// // Group items by category, sorted by expiry date
/// final grouped = useCase(allItems);
///
/// // Group items by category, sorted by quantity
/// final groupedByQuantity = useCase(
///   allItems,
///   sortFilter: SortFilter.quantityAsc,
/// );
///
/// // Get sorted category names
/// final categories = useCase.sortCategories(grouped.keys.toList());
/// ```
class GroupFridgeItemsUseCase {
  /// Groups fridge items by category and applies sorting.
  ///
  /// Parameters:
  /// - [items]: The list of fridge items to group and sort
  /// - [sortFilter]: The sorting criteria within each category (default: by expiry date)
  ///
  /// Returns a map where:
  /// - Key: Category name (or "その他" for uncategorized items)
  /// - Value: List of items in that category, sorted by the specified filter
  Map<String, List<FridgeItem>> call(
    List<FridgeItem> items, {
    SortFilter sortFilter = SortFilter.expiryDateAsc,
  }) {
    final Map<String, List<FridgeItem>> grouped = {};

    // Group items by category
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

  /// Sorts category names alphabetically with "その他" (Other) always last.
  ///
  /// This ensures a consistent category display order in the UI
  /// with uncategorized items appearing at the bottom.
  ///
  /// Parameters:
  /// - [categories]: List of category names to sort
  ///
  /// Returns a sorted list where:
  /// - All categories are in alphabetical order
  /// - "その他" always appears last
  List<String> sortCategories(List<String> categories) {
    return categories.toList()
      ..sort((a, b) {
        if (a == 'その他') return 1;
        if (b == 'その他') return -1;
        return a.compareTo(b);
      });
  }
}
