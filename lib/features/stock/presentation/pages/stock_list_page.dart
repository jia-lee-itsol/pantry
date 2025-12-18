import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/stock_provider.dart';
import '../../domain/entities/stock_item.dart';
import '../widgets/edit_stock_item_bottom_sheet.dart';
import 'add_stock_item_page.dart';

class StockListPage extends ConsumerStatefulWidget {
  const StockListPage({super.key});

  @override
  ConsumerState<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends ConsumerState<StockListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 아이템명으로부터 카테고리를 추측합니다.
  String _getCategoryFromName(String name) {
    final lowerName = name.toLowerCase();

    // 통조림/가공식품 (더 구체적인 카테고리를 먼저 확인)
    if (lowerName.contains('缶詰') ||
        (lowerName.contains('缶') && !lowerName.contains('飲料')) ||
        lowerName.contains('canned')) {
      return '缶詰/加工食品';
    }

    // 飲料水/飲み物
    if (lowerName.contains('水') ||
        lowerName.contains('飲料') ||
        (lowerName.contains('缶') && lowerName.contains('飲料')) ||
        lowerName.contains('drink') ||
        lowerName.contains('water')) {
      return '飲料水/飲み物';
    }

    // 主食類
    if (lowerName.contains('米') ||
        lowerName.contains('ラーメン') ||
        lowerName.contains('乾パン') ||
        lowerName.contains('rice') ||
        lowerName.contains('noodle') ||
        lowerName.contains('ramen')) {
      return '主食類';
    }

    // 乳製品
    if (lowerName.contains('牛乳') ||
        lowerName.contains('チーズ') ||
        lowerName.contains('milk') ||
        lowerName.contains('cheese')) {
      return '乳製品';
    }

    // その他
    return 'その他';
  }

  /// 아이템을 카테고리별로 그룹화합니다.
  Map<String, List<StockItem>> _groupByCategory(List<StockItem> items) {
    final Map<String, List<StockItem>> grouped = {};

    for (final item in items) {
      // 아이템에 카테고리가 있으면 사용하고, 없으면 이름으로부터 추측
      final category = item.category ?? _getCategoryFromName(item.name);
      grouped.putIfAbsent(category, () => []).add(item);
    }

    // 각 카테고리 내 아이템을 유통기한 순으로 정렬 (긴 순)
    // 유통기한이 없는 경우 맨 아래에
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return b.expiryDate!.compareTo(a.expiryDate!);
      });
    }

    // 카테고리 순서로 정렬 (식수/음료, 주식류, 통조림/가공식품, 유제품, 기타)
    final categoryOrder = ['飲料水/飲み物', '主食類', '缶詰/加工食品', '乳製品', 'その他'];
    final sortedGrouped = <String, List<StockItem>>{};

    for (final category in categoryOrder) {
      if (grouped.containsKey(category)) {
        sortedGrouped[category] = grouped[category]!;
      }
    }

    // 기타 카테고리에 포함되지 않는 항목 추가
    for (final entry in grouped.entries) {
      if (!categoryOrder.contains(entry.key)) {
        sortedGrouped[entry.key] = entry.value;
      }
    }

    return sortedGrouped;
  }

  /// 카테고리에 해당하는 아이콘을 반환합니다.
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '飲料水/飲み物':
        return Icons.water_drop;
      case '主食類':
        return Icons.rice_bowl;
      case '缶詰/加工食品':
        return Icons.inventory_2;
      case '乳製品':
        return Icons.egg;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockItemsAsync = ref.watch(stockItemsProvider);
    final searchQuery = _searchController.text.toLowerCase();

    return AppScaffold(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '商品名検索...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
            )
          : const Text('災害備蓄品'),
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
        label: '재고 아이템 추가',
        button: true,
        child: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddStockItemPage()),
          );
          // 페이지에서 돌아오면 리스트 업데이트
          if (context.mounted) {
            ref.invalidate(stockItemsProvider);
          }
        },
          child: const Icon(Icons.add),
        ),
      ),
      body: stockItemsAsync.when(
        data: (items) {
          // 검색 필터링
          final filteredItems = searchQuery.isEmpty
              ? items
              : items.where((item) {
                  return item.name.toLowerCase().contains(searchQuery);
                }).toList();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '備蓄品がありません。',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '右下の+ボタンを押して\n備蓄品を追加してみてください。',
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
          final groupedItems = _groupByCategory(filteredItems);

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: groupedItems.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final category = groupedItems.keys.elementAt(index);
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
                                  color: Theme.of(context).colorScheme.primary,
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
                      ...items.asMap().entries.map(
                        (entry) {
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            child: Semantics(
                              label: '${item.name}, 수량: ${item.quantity}${item.expiryDate != null ? ', 유통기한: ${item.expiryDate!.year}년 ${item.expiryDate!.month}월 ${item.expiryDate!.day}일' : ''}',
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
                                        EditStockItemBottomSheet(item: item),
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
                                        Text(
                                          item.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '数量: ${item.quantity}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                        ),
                                        if (item.expiryDate != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '賞味期限: ${item.expiryDate!.year}/${item.expiryDate!.month}/${item.expiryDate!.day}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Semantics(
                                    label: '${item.name} 삭제',
                                    button: true,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline),
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
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('キャンセル'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('削除'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true && mounted) {
                                        try {
                                          await ref
                                              .read(stockRepositoryProvider)
                                              .deleteStockItem(item.id);
                                          if (mounted) {
                                            ref.invalidate(stockItemsProvider);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('備蓄品を削除しました。'),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('削除失敗: $e'),
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
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
                Semantics(
                  label: '재시도',
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(stockItemsProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('再試行'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
