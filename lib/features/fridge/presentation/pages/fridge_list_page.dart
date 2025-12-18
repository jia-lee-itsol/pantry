import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/fridge_item.dart';
import '../providers/fridge_provider.dart';
import '../widgets/edit_fridge_item_bottom_sheet.dart';
import 'add_fridge_item_page.dart';

class FridgeListPage extends ConsumerStatefulWidget {
  const FridgeListPage({super.key});

  @override
  ConsumerState<FridgeListPage> createState() => _FridgeListPageState();
}

enum SortFilter {
  expiryDateAsc, // 유통기한 짧은순
  quantityAsc, // 수량 적은 순
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

  /// 카테고리에 해당하는 아이콘을 반환합니다.
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
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '商品名検索...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.black),
              onChanged: (_) => setState(() {}),
            )
          : Text(AppStrings.fridgeList),
      actions: [
        if (_isSearching)
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
          )
        else
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
      ],
      floatingActionButton: Semantics(
        label: '냉장고 아이템 추가',
        button: true,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddFridgeItemPage(),
              ),
            );
            // 페이지에서 돌아오면 리스트 업데이트
            if (context.mounted) {
              ref.invalidate(fridgeItemsProvider);
            }
          },
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
      body: fridgeItemsAsync.when(
        data: (items) {
          // 검색 필터링
          final filteredItems = searchQuery.isEmpty
              ? items
              : items.where((item) {
                  return item.name.toLowerCase().contains(searchQuery) ||
                      (item.category?.toLowerCase().contains(searchQuery) ??
                          false);
                }).toList();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.kitchen_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '冷蔵庫の在庫がありません。',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '右下の+ボタンを押して\n商品を追加してみてください。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (filteredItems.isEmpty && searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '検索結果がありません。',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '「$searchQuery」の検索結果がありません。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // 카테고리별로 그룹화
          final Map<String, List<FridgeItem>> groupedItems = {};
          for (final item in filteredItems) {
            final category = item.category ?? 'その他';
            groupedItems.putIfAbsent(category, () => []).add(item);
          }

          // 각 카테고리 내 아이템을 선택된 필터에 따라 정렬
          for (final category in groupedItems.keys) {
            groupedItems[category]!.sort((a, b) {
              switch (_selectedFilter) {
                case SortFilter.expiryDateAsc:
                  // 유통기한 짧은순
                  return a.expiryDate.compareTo(b.expiryDate);
                case SortFilter.quantityAsc:
                  // 수량 적은 순
                  return a.quantity.compareTo(b.quantity);
              }
            });
          }

          // 카테고리명으로 정렬
          final sortedCategories = groupedItems.keys.toList()
            ..sort((a, b) {
              if (a == 'その他') return 1;
              if (b == 'その他') return -1;
              return a.compareTo(b);
            });

          return Column(
            children: [
              // 필터 탭
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: SegmentedButton<SortFilter>(
                  segments: [
                    ButtonSegment<SortFilter>(
                      value: SortFilter.expiryDateAsc,
                      label: const Text(
                        '賞味期限順',
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                    ButtonSegment<SortFilter>(
                      value: SortFilter.quantityAsc,
                      label: const Text(
                        '数量順',
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: const Icon(
                        Icons.inventory,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  selected: {_selectedFilter},
                  onSelectionChanged: (Set<SortFilter> newSelection) {
                    setState(() {
                      _selectedFilter = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // 아이템 리스트
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: sortedCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final category = sortedCategories[index];
                    final items = groupedItems[category]!;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 카테고리 헤더
                            Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  category,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  '${items.length}個',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.sm),
                            // 카테고리 내 아이템 목록
                            ...items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                child: Dismissible(
                                  key: Key(item.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '消費',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    // 수량을 1 감소
                                    final newQuantity = item.quantity - 1;

                                    if (newQuantity <= 0) {
                                      // 수량이 0 이하이면 삭제
                                      try {
                                        await ref
                                            .read(fridgeRepositoryProvider)
                                            .deleteFridgeItem(item.id);
                                        if (mounted) {
                                          ref.invalidate(fridgeItemsProvider);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${item.name}を消費して削除しました。',
                                              ),
                                            ),
                                          );
                                        }
                                        return true; // dismiss許可（削除済み）
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('消費処理失敗: $e'),
                                            ),
                                          );
                                        }
                                        return false; // dismissキャンセル
                                      }
                                    } else {
                                      // 수량이 남아있으면 업데이트 (위젯은 삭제하지 않음)
                                      try {
                                        final updatedItem = item.copyWith(
                                          quantity: newQuantity,
                                          updatedAt: DateTime.now(),
                                        );
                                        await ref
                                            .read(fridgeRepositoryProvider)
                                            .updateFridgeItem(updatedItem);
                                        if (mounted) {
                                          ref.invalidate(fridgeItemsProvider);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${item.name} 数量: ${item.quantity} → $newQuantity',
                                              ),
                                            ),
                                          );
                                        }
                                        return false; // dismissキャンセル（ウィジェット維持、数量のみ更新）
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('消費処理失敗: $e'),
                                            ),
                                          );
                                        }
                                        return false; // dismissキャンセル
                                      }
                                    }
                                  },
                                  child: Semantics(
                                    label:
                                        '${item.name}, 수량: ${item.quantity}, 유통기한: ${item.expiryDate.year}년 ${item.expiryDate.month}월 ${item.expiryDate.day}일',
                                    button: true,
                                    child: InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (context) =>
                                              EditFridgeItemBottomSheet(
                                                item: item,
                                              ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs,
                                          vertical: AppSpacing.xs,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.bodyLarge,
                                                      ),
                                                      if (item.isFrozen) ...[
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Icon(
                                                          Icons.ac_unit,
                                                          color: Colors
                                                              .blue
                                                              .shade400,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '数量: ${item.quantity}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                  ),
                                                  if (!item.isFrozen) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '賞味期限: ${item.expiryDate.year}/${item.expiryDate.month}/${item.expiryDate.day}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            if (item.isFrozen)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: AppSpacing.xs,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.ac_unit,
                                                      color:
                                                          Colors.blue.shade400,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '冷凍',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .blue
                                                            .shade400,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            Semantics(
                                              label: '${item.name} 삭제',
                                              button: true,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                color: Colors.grey.shade600,
                                                onPressed: () async {
                                                  final confirmed = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('削除確認'),
                                                      content: Text(
                                                        '${item.name}を削除しますか？',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(false),
                                                          child: const Text(
                                                            'キャンセル',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(true),
                                                          style:
                                                              TextButton.styleFrom(
                                                                foregroundColor:
                                                                    Colors.red,
                                                              ),
                                                          child: const Text(
                                                            '削除',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirmed == true &&
                                                      mounted) {
                                                    try {
                                                      await ref
                                                          .read(
                                                            fridgeRepositoryProvider,
                                                          )
                                                          .deleteFridgeItem(
                                                            item.id,
                                                          );
                                                      if (mounted) {
                                                        ref.invalidate(
                                                          fridgeItemsProvider,
                                                        );
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              '冷蔵庫アイテムを削除しました。',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              '削除失敗: $e',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'データを読み込めませんでした。',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'ネットワーク接続を確認するか\nしばらく経ってから再試行してください。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(fridgeItemsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
