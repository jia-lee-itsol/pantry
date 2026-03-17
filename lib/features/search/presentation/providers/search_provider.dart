import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_items_usecase.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';

// Search Use Case Provider
final searchItemsUseCaseProvider = Provider<SearchItemsUseCase>((ref) {
  return SearchItemsUseCase();
});

// Search Filter State Provider
class SearchFilterNotifier extends Notifier<SearchFilter> {
  @override
  SearchFilter build() => const SearchFilter();

  void setFilter(SearchFilter filter) {
    state = filter;
  }

  void updateQuery(String? query) {
    state = state.copyWith(query: query);
  }

  void clearFilters() {
    state = const SearchFilter();
  }
}

final searchFilterProvider =
    NotifierProvider<SearchFilterNotifier, SearchFilter>(
  () => SearchFilterNotifier(),
);

// Search Results Provider
final searchResultsProvider = Provider<AsyncValue<List<SearchResult>>>((ref) {
  final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
  final stockItemsAsync = ref.watch(stockItemsProvider);
  final filter = ref.watch(searchFilterProvider);
  final searchUseCase = ref.read(searchItemsUseCaseProvider);

  // Wait for both data sources
  if (fridgeItemsAsync.isLoading || stockItemsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (fridgeItemsAsync.hasError) {
    return AsyncValue.error(fridgeItemsAsync.error!, fridgeItemsAsync.stackTrace!);
  }

  if (stockItemsAsync.hasError) {
    return AsyncValue.error(stockItemsAsync.error!, stockItemsAsync.stackTrace!);
  }

  final fridgeItems = fridgeItemsAsync.value ?? [];
  final stockItems = stockItemsAsync.value ?? [];

  final results = searchUseCase(
    fridgeItems: fridgeItems,
    stockItems: stockItems,
    filter: filter,
  );

  return AsyncValue.data(results);
});

// All Categories Provider (for filter chips)
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
