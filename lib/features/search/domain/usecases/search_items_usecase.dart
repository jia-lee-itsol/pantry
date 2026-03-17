import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';
import '../entities/search_filter.dart';
import '../entities/search_result.dart';

/// Use Case for searching across fridge and stock items.
class SearchItemsUseCase {
  List<SearchResult> call({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
    required SearchFilter filter,
  }) {
    final results = <SearchResult>[];

    // Convert fridge items to search results
    if (filter.sources.contains(SearchResultSource.fridge)) {
      for (final item in fridgeItems) {
        results.add(SearchResult(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          category: item.category,
          expiryDate: item.expiryDate,
          source: SearchResultSource.fridge,
          isFrozen: item.isFrozen,
          targetQuantity: item.targetQuantity,
        ));
      }
    }

    // Convert stock items to search results
    if (filter.sources.contains(SearchResultSource.stock)) {
      for (final item in stockItems) {
        results.add(SearchResult(
          id: item.id,
          name: item.name,
          quantity: item.quantity,
          category: item.category,
          expiryDate: item.expiryDate,
          source: SearchResultSource.stock,
          targetQuantity: item.targetQuantity,
        ));
      }
    }

    // Apply filters
    return _applyFilters(results, filter);
  }

  List<SearchResult> _applyFilters(List<SearchResult> results, SearchFilter filter) {
    var filtered = results.toList();

    // Filter by query
    if (filter.query != null && filter.query!.isNotEmpty) {
      final query = filter.query!.toLowerCase();
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(query) ||
            (item.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter by categories
    if (filter.categories.isNotEmpty) {
      filtered = filtered.where((item) {
        return filter.categories.contains(item.category);
      }).toList();
    }

    // Filter by low stock
    if (filter.showOnlyLowStock == true) {
      filtered = filtered.where((item) => item.isLowStock).toList();
    }

    // Filter by near expiry
    if (filter.showOnlyNearExpiry == true) {
      filtered = filtered.where((item) => item.isNearExpiry).toList();
    }

    // Filter by expired
    if (filter.showOnlyExpired == true) {
      filtered = filtered.where((item) => item.isExpired).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return filtered;
  }
}
