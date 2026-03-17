import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_result.dart';
import '../providers/search_provider.dart';

class SearchFilterSheet extends ConsumerStatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  ConsumerState<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends ConsumerState<SearchFilterSheet> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(searchFilterProvider);
  }

  void _applyFilters() {
    ref.read(searchFilterProvider.notifier).setFilter(_filter);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = ref.watch(allCategoriesProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSourceSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusSection(),
                  const SizedBox(height: AppSpacing.lg),
                  if (allCategories.isNotEmpty) ...[
                    _buildCategorySection(allCategories),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _buildApplyButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Text(
            'フィルター',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '検索対象',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            FilterChip(
              label: const Text('冷蔵庫'),
              selected: _filter.sources.contains(SearchResultSource.fridge),
              onSelected: (selected) {
                setState(() {
                  final sources = Set<SearchResultSource>.from(_filter.sources);
                  if (selected) {
                    sources.add(SearchResultSource.fridge);
                  } else if (sources.length > 1) {
                    sources.remove(SearchResultSource.fridge);
                  }
                  _filter = _filter.copyWith(sources: sources);
                });
              },
            ),
            FilterChip(
              label: const Text('備蓄品'),
              selected: _filter.sources.contains(SearchResultSource.stock),
              onSelected: (selected) {
                setState(() {
                  final sources = Set<SearchResultSource>.from(_filter.sources);
                  if (selected) {
                    sources.add(SearchResultSource.stock);
                  } else if (sources.length > 1) {
                    sources.remove(SearchResultSource.stock);
                  }
                  _filter = _filter.copyWith(sources: sources);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '状態',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            FilterChip(
              label: const Text('在庫不足'),
              selected: _filter.showOnlyLowStock == true,
              onSelected: (selected) {
                setState(() {
                  _filter = _filter.copyWith(showOnlyLowStock: selected ? true : null);
                });
              },
            ),
            FilterChip(
              label: const Text('期限間近'),
              selected: _filter.showOnlyNearExpiry == true,
              onSelected: (selected) {
                setState(() {
                  _filter = _filter.copyWith(showOnlyNearExpiry: selected ? true : null);
                });
              },
            ),
            FilterChip(
              label: const Text('期限切れ'),
              selected: _filter.showOnlyExpired == true,
              onSelected: (selected) {
                setState(() {
                  _filter = _filter.copyWith(showOnlyExpired: selected ? true : null);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(Set<String> allCategories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'カテゴリ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: allCategories.map((category) {
            return FilterChip(
              label: Text(category),
              selected: _filter.categories.contains(category),
              onSelected: (selected) {
                setState(() {
                  final categories = Set<String>.from(_filter.categories);
                  if (selected) {
                    categories.add(category);
                  } else {
                    categories.remove(category);
                  }
                  _filter = _filter.copyWith(categories: categories);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      onPressed: _applyFilters,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      ),
      child: const Text('適用'),
    );
  }
}
