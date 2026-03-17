import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_result.dart';
import '../providers/search_provider.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/search_filter_sheet.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchFilterProvider.notifier).updateQuery(
      query.isEmpty ? null : query,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SearchFilterSheet(),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(searchFilterProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final filter = ref.watch(searchFilterProvider);

    return AppScaffold(
      title: const Text('検索'),
      body: Column(
        children: [
          _buildSearchBar(filter),
          _buildFilterChips(filter),
          Expanded(child: _buildResults(searchResultsAsync)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SearchFilter filter) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '商品名やカテゴリで検索...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Badge(
            isLabelVisible: filter.hasActiveFilters,
            child: IconButton(
              onPressed: _showFilterSheet,
              icon: const Icon(Icons.tune),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(SearchFilter filter) {
    if (!filter.hasActiveFilters) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (filter.sources.length < 2)
              _buildChip(
                filter.sources.first == SearchResultSource.fridge ? '冷蔵庫のみ' : '備蓄品のみ',
              ),
            if (filter.showOnlyLowStock == true)
              _buildChip('在庫不足'),
            if (filter.showOnlyNearExpiry == true)
              _buildChip('期限間近'),
            if (filter.showOnlyExpired == true)
              _buildChip('期限切れ'),
            for (final category in filter.categories)
              _buildChip(category),
            const SizedBox(width: AppSpacing.xs),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('クリア'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildResults(AsyncValue<List<SearchResult>> resultsAsync) {
    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: results.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            return SearchResultTile(result: results[index]);
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: AppSpacing.md),
            Text('エラーが発生しました: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final filter = ref.watch(searchFilterProvider);
    final hasQuery = filter.query?.isNotEmpty ?? false;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasQuery ? '検索結果がありません' : '商品を検索してください',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          if (hasQuery) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '別のキーワードで検索してみてください',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
