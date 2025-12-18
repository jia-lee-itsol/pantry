import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../stock/domain/entities/stock_item.dart';
import '../../presentation/providers/shopping_list_provider.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../widgets/low_stock_item_card.dart';

/// 재고 부족 상품 리스트 페이지
class LowStockListPage extends ConsumerWidget {
  const LowStockListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockItemsAsync = ref.watch(stockItemsProvider);
    final shoppingListAsync = ref.watch(shoppingListProvider);

    return AppScaffold(
      title: const Text('在庫不足商品'),
      body: stockItemsAsync.when(
        data: (items) {
          // 재고 부족 아이템 필터링
          final lowStockItems = items.where((item) {
            if (item.targetQuantity != null) {
              return item.quantity < item.targetQuantity!;
            } else {
              return item.quantity < 5; // 기본값
            }
          }).toList();


          if (lowStockItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '在庫不足商品がありません',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'すべての商品が目標数量を満たしています',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(stockItemsProvider);
              ref.invalidate(shoppingListProvider);
            },
            child: shoppingListAsync.when(
              data: (shoppingItems) => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: lowStockItems.length,
                itemBuilder: (context, index) {
                  final item = lowStockItems[index];
                  final targetQty = item.targetQuantity ?? 5;
                  final neededQuantity = targetQty - item.quantity;
                  
                  // 구매 리스트에 이미 추가되어 있는지 확인
                  // 이름이 정확히 일치하거나, 수량이 포함된 이름과 일치하는지 확인
                  final isAdded = shoppingItems.any((shoppingItem) {
                    if (shoppingItem.category != 'stock') return false;
                    // 정확한 이름 일치
                    if (shoppingItem.name == item.name) return true;
                    // 수량이 포함된 이름과 일치 (예: "商品名 (数量: 3)")
                    if (neededQuantity > 1) {
                      final expectedName = '${item.name} (数量: $neededQuantity)';
                      if (shoppingItem.name == expectedName) return true;
                    }
                    // 이름이 포함되어 있는지 확인 (부분 일치)
                    return shoppingItem.name.contains(item.name) &&
                        shoppingItem.name.contains('数量');
                  });

                  return LowStockItemCard(
                    item: item,
                    isAdded: isAdded,
                    onAddToShoppingList: isAdded
                        ? null
                        : () async {
                            // mounted 체크를 비동기 작업 전에 수행
                            if (!context.mounted) return;
                            
                            try {
                              await _addToShoppingList(ref, item);
                              
                              // 작업 완료 후 다시 mounted 체크
                              if (!context.mounted) return;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name}を買い物リストに追加しました'),
                                  duration: const Duration(seconds: 3),
                                  action: SnackBarAction(
                                    label: '確認',
                                    onPressed: () {
                                      if (context.mounted) {
                                        context.go('/list?category=stock');
                                      }
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('追加に失敗しました: $e'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                  );
                },
              ),
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: lowStockItems.length,
                itemBuilder: (context, index) {
                  final item = lowStockItems[index];
                  return LowStockItemCard(
                    item: item,
                    isAdded: false,
                    onAddToShoppingList: () async {
                      if (!context.mounted) return;
                      try {
                        await _addToShoppingList(ref, item);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name}を買い物リストに追加しました'),
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: '確認',
                              onPressed: () {
                                if (context.mounted) {
                                  context.go('/list?category=stock');
                                }
                              },
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('追加に失敗しました: $e'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              error: (_, __) => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: lowStockItems.length,
                itemBuilder: (context, index) {
                  final item = lowStockItems[index];
                  return LowStockItemCard(
                    item: item,
                    isAdded: false,
                    onAddToShoppingList: () async {
                      if (!context.mounted) return;
                      try {
                        await _addToShoppingList(ref, item);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name}を買い物リストに追加しました'),
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: '確認',
                              onPressed: () {
                                if (context.mounted) {
                                  context.go('/list?category=stock');
                                }
                              },
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('追加に失敗しました: $e'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'データを読み込めませんでした',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(stockItemsProvider);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 구매 리스트에 아이템 추가
  Future<void> _addToShoppingList(
    WidgetRef ref,
    StockItem item,
  ) async {
    final targetQty = item.targetQuantity ?? 5;
    final neededQuantity = targetQty - item.quantity;

    // 구매 리스트 아이템 생성 (이름에 수량 포함)
    final shoppingItem = ShoppingListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: neededQuantity > 1
          ? '${item.name} (数量: $neededQuantity)'
          : item.name,
      category: 'stock',
      isCompleted: false,
    );

    await ref.read(shoppingListProvider.notifier).addItem(shoppingItem);
  }
}

