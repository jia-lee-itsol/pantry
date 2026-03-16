import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/fridge_item.dart';
import '../providers/fridge_provider.dart';
import '../widgets/sort_filter_bar.dart';
import '../widgets/fridge_item_row.dart';
import '../widgets/fridge_empty_state.dart';
import 'add_fridge_item_page.dart';

class FridgeListPage extends ConsumerStatefulWidget {
  const FridgeListPage({super.key});

  @override
  ConsumerState<FridgeListPage> createState() => _FridgeListPageState();
}

class _FridgeListPageState extends ConsumerState<FridgeListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  SortFilter _selectedFilter = SortFilter.expiryDateAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '果物':
        return Icons.apple;
      case 'タンパク質':
        return Icons.egg;
      case '乳製品':
        return Icons.local_drink;
      case '野菜':
        return Icons.eco;
      case '冷凍食品':
        return Icons.ac_unit;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
    final searchQuery = _searchController.text.toLowerCase();

    return AppScaffold(
      title: _buildTitle(),
      actions: _buildActions(),
      floatingActionButton: _buildFloatingActionButton(),
      body: fridgeItemsAsync.when(
        data: (items) => _buildContent(items, searchQuery),
        loading: () => const LoadingWidget(),
        error: (_, _) => FridgeErrorState(
          onRetry: () => ref.invalidate(fridgeItemsProvider),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '商品名検索...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (_) => setState(() {}),
      );
    }
    return Text(AppStrings.fridgeList);
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return [
        Semantics(
          label: '검색 취소',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _isSearching = false;
              });
            },
          ),
        ),
      ];
    }
    return [
      Semantics(
        label: '검색',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ),
    ];
  }

  Widget _buildFloatingActionButton() {
    return Semantics(
      label: '냉장고 아이템 추가',
      button: true,
      child: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddFridgeItemPage(),
            ),
          );
          if (mounted) {
            ref.invalidate(fridgeItemsProvider);
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildContent(List<FridgeItem> items, String searchQuery) {
    final filteredItems = searchQuery.isEmpty
        ? items
        : items.where((item) {
            return item.name.toLowerCase().contains(searchQuery) ||
                (item.category?.toLowerCase().contains(searchQuery) ?? false);
          }).toList();

    if (items.isEmpty) {
      return const FridgeEmptyState();
    }

    if (filteredItems.isEmpty && searchQuery.isNotEmpty) {
      return FridgeSearchEmptyState(searchQuery: searchQuery);
    }

    final groupedItems = _groupAndSortItems(filteredItems);
    final sortedCategories = groupedItems.keys.toList()
      ..sort((a, b) {
        if (a == 'その他') return 1;
        if (b == 'その他') return -1;
        return a.compareTo(b);
      });

    return Column(
      children: [
        SortFilterBar(
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sortedCategories.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              final categoryItems = groupedItems[category]!;
              return _buildCategoryCard(category, categoryItems);
            },
          ),
        ),
      ],
    );
  }

  Map<String, List<FridgeItem>> _groupAndSortItems(List<FridgeItem> items) {
    final Map<String, List<FridgeItem>> groupedItems = {};
    for (final item in items) {
      final category = item.category ?? 'その他';
      groupedItems.putIfAbsent(category, () => []).add(item);
    }

    for (final category in groupedItems.keys) {
      groupedItems[category]!.sort((a, b) {
        switch (_selectedFilter) {
          case SortFilter.expiryDateAsc:
            return a.expiryDate.compareTo(b.expiryDate);
          case SortFilter.quantityAsc:
            return a.quantity.compareTo(b.quantity);
        }
      });
    }

    return groupedItems;
  }

  Widget _buildCategoryCard(String category, List<FridgeItem> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(category, items.length),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            ...items.map((item) => FridgeItemRow(item: item)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String category, int itemCount) {
    return Row(
      children: [
        Icon(
          _getCategoryIcon(category),
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          category,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const Spacer(),
        Text(
          '$itemCount個',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
