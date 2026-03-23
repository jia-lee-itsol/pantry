import 'search_result.dart';

/// Domain entity representing filter criteria for searching items.
///
/// This entity encapsulates all possible filter options including text query,
/// source filtering, category filtering, and status-based filters (low stock,
/// near expiry, expired).
class SearchFilter {
  /// Text query for searching by item name
  final String? query;

  /// Set of sources to search in (fridge and/or stock)
  final Set<SearchResultSource> sources;

  /// Set of categories to filter by
  final Set<String> categories;

  /// Whether to show only items with low stock
  final bool? showOnlyLowStock;

  /// Whether to show only items nearing expiration
  final bool? showOnlyNearExpiry;

  /// Whether to show only expired items
  final bool? showOnlyExpired;

  /// Creates a [SearchFilter] instance.
  ///
  /// By default, searches both fridge and stock with no other filters applied.
  const SearchFilter({
    this.query,
    this.sources = const {SearchResultSource.fridge, SearchResultSource.stock},
    this.categories = const {},
    this.showOnlyLowStock,
    this.showOnlyNearExpiry,
    this.showOnlyExpired,
  });

  /// Creates a copy of this filter with the given fields replaced.
  ///
  /// Returns a new [SearchFilter] instance with updated values for any
  /// non-null parameters, keeping existing values for null parameters.
  SearchFilter copyWith({
    String? query,
    Set<SearchResultSource>? sources,
    Set<String>? categories,
    bool? showOnlyLowStock,
    bool? showOnlyNearExpiry,
    bool? showOnlyExpired,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      sources: sources ?? this.sources,
      categories: categories ?? this.categories,
      showOnlyLowStock: showOnlyLowStock ?? this.showOnlyLowStock,
      showOnlyNearExpiry: showOnlyNearExpiry ?? this.showOnlyNearExpiry,
      showOnlyExpired: showOnlyExpired ?? this.showOnlyExpired,
    );
  }

  /// Checks if any filters are currently active.
  ///
  /// Returns true if there's a search query, limited sources, selected
  /// categories, or any status filters enabled.
  bool get hasActiveFilters {
    return (query?.isNotEmpty ?? false) ||
        sources.length < 2 ||
        categories.isNotEmpty ||
        showOnlyLowStock == true ||
        showOnlyNearExpiry == true ||
        showOnlyExpired == true;
  }
}
