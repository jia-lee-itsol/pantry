import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_items_usecase.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';

/// Provider for the search items use case.
///
/// Creates an instance of [SearchItemsUseCase] for searching and filtering items.
final searchItemsUseCaseProvider = Provider<SearchItemsUseCase>((ref) {
  return SearchItemsUseCase();
});

/// Notifier for managing search filter state.
///
/// This notifier maintains the current search filter configuration and
/// provides methods to update it.
class SearchFilterNotifier extends Notifier<SearchFilter> {
  /// Initializes the filter with default values (no filters applied).
  @override
  SearchFilter build() => const SearchFilter();

  /// Sets a complete filter configuration.
  ///
  /// Parameters:
  ///   [filter] - The new filter to apply
  void setFilter(SearchFilter filter) {
    state = filter;
  }

  /// Updates only the search query while keeping other filters.
  ///
  /// Parameters:
  ///   [query] - The new search query text
  void updateQuery(String? query) {
    state = state.copyWith(query: query);
  }

  /// Resets all filters to their default values.
  void clearFilters() {
    state = const SearchFilter();
  }
}

/// Provider for the search filter state.
///
/// Exposes the current filter configuration and allows updating it
/// through the [SearchFilterNotifier].
final searchFilterProvider =
    NotifierProvider<SearchFilterNotifier, SearchFilter>(
  () => SearchFilterNotifier(),
);

/// Provider for search results based on current filters.
///
/// Combines items from both fridge and stock, applies the current filter,
/// and returns matching results. Automatically updates when filter or
/// inventory changes.
final searchResultsProvider = Provider<AsyncValue<List<SearchResult>>>((ref) {
  final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
  final stockItemsAsync = ref.watch(stockItemsProvider);
  final filter = ref.watch(searchFilterProvider);
  final searchUseCase = ref.read(searchItemsUseCaseProvider);

  // Wait for both data sources to load
  if (fridgeItemsAsync.isLoading || stockItemsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  // Handle errors from either source
  if (fridgeItemsAsync.hasError) {
    return AsyncValue.error(fridgeItemsAsync.error!, fridgeItemsAsync.stackTrace!);
  }

  if (stockItemsAsync.hasError) {
    return AsyncValue.error(stockItemsAsync.error!, stockItemsAsync.stackTrace!);
  }

  final fridgeItems = fridgeItemsAsync.value ?? [];
  final stockItems = stockItemsAsync.value ?? [];

  // Execute search with current filter
  final results = searchUseCase(
    fridgeItems: fridgeItems,
    stockItems: stockItems,
    filter: filter,
  );

  return AsyncValue.data(results);
});

/// Provider for all available categories from both fridge and stock.
///
/// Collects unique categories from all items to populate filter options.
/// Updates automatically when inventory changes.
final allCategoriesProvider = Provider<Set<String>>((ref) {
  final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
  final stockItemsAsync = ref.watch(stockItemsProvider);

  final categories = <String>{};

  if (fridgeItemsAsync.hasValue) {
    for (final item in fridgeItemsAsync.value!) {
      if (item.category != null) {
        categories.add(item.category!);
      }
    }
  }

  if (stockItemsAsync.hasValue) {
    for (final item in stockItemsAsync.value!) {
      if (item.category != null) {
        categories.add(item.category!);
      }
    }
  }

  return categories;
});
