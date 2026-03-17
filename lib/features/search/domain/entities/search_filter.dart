import 'search_result.dart';

/// Filter options for advanced search.
class SearchFilter {
  final String? query;
  final Set<SearchResultSource> sources;
  final Set<String> categories;
  final bool? showOnlyLowStock;
  final bool? showOnlyNearExpiry;
  final bool? showOnlyExpired;

  const SearchFilter({
    this.query,
    this.sources = const {SearchResultSource.fridge, SearchResultSource.stock},
    this.categories = const {},
    this.showOnlyLowStock,
    this.showOnlyNearExpiry,
    this.showOnlyExpired,
  });

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

  bool get hasActiveFilters {
    return (query?.isNotEmpty ?? false) ||
        sources.length < 2 ||
        categories.isNotEmpty ||
        showOnlyLowStock == true ||
        showOnlyNearExpiry == true ||
        showOnlyExpired == true;
  }
}
