import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/add_shopping_item_dialog.dart';
import '../widgets/edit_shopping_item_dialog.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// name에서 상품명과 수량 파싱
/// 예: "商品名 (数量: 3)" -> {name: "商品名", quantity: 3}
/// 예: "商品名" -> {name: "商品名", quantity: 1}
Map<String, dynamic> _parseNameAndQuantity(String name) {
  final quantityPattern = RegExp(r'\(数量:\s*(\d+)\)');
  final match = quantityPattern.firstMatch(name);
  
  if (match != null) {
    final quantity = int.tryParse(match.group(1) ?? '1') ?? 1;
    final itemName = name.substring(0, match.start).trim();
    return {'name': itemName, 'quantity': quantity};
  } else {
    return {'name': name, 'quantity': 1};
  }
}

class ListPage extends ConsumerStatefulWidget {
  const ListPage({super.key});

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  String _selectedCategory = 'fridge'; // 'fridge' または 'stock'

  /// 재고 확인하여 자동 완료 처리
  /// 냉장고와 비축품 모두 확인하여 총 합으로 계산
  Future<ShoppingListItem> _checkStockAndAutoComplete(
    WidgetRef ref,
    ShoppingListItem item,
    String category,
  ) async {
    final parsed = _parseNameAndQuantity(item.name);
    final neededQuantity = parsed['quantity'] as int;

    int totalStock = 0;

    try {
      // 냉장고와 비축품 모두 확인하여 총 합 계산
      final fridgeItems = await ref.read(fridgeItemsProvider.future);
      final matchingFridgeItems = _findAllMatchingFridgeItems(item.name, fridgeItems);
      for (final fridgeItem in matchingFridgeItems) {
        totalStock += fridgeItem.quantity;
      }

      final stockItems = await ref.read(stockItemsProvider.future);
      final matchingStockItems = _findAllMatchingStockItems(item.name, stockItems);
      for (final stockItem in matchingStockItems) {
        totalStock += stockItem.quantity;
      }
    } catch (e) {
      // 에러 발생 시 재고 부족으로 처리
      totalStock = 0;
    }

    // 총 재고가 필요한 수량 이상이면 충분
    final hasEnoughStock = totalStock >= neededQuantity;

    // 재고가 충분하면 자동으로 완료 처리
    return item.copyWith(isCompleted: hasEnoughStock);
  }

  /// 쇼핑 리스트 아이템 이름과 매칭되는 모든 냉장고 아이템 찾기 (총 합 계산용)
  List<FridgeItem> _findAllMatchingFridgeItems(String itemName, List<FridgeItem> fridgeItems) {
    final parsed = _parseNameAndQuantity(itemName);
    final cleanName = (parsed['name'] as String).toLowerCase().trim();
    final matchingItems = <FridgeItem>[];
    
    for (final fridgeItem in fridgeItems) {
      final fridgeName = fridgeItem.name.toLowerCase().trim();
      if (fridgeName == cleanName || 
          fridgeName.contains(cleanName) || 
          cleanName.contains(fridgeName)) {
        matchingItems.add(fridgeItem);
      }
    }
    return matchingItems;
  }

  /// 쇼핑 리스트 아이템 이름과 매칭되는 모든 재고 아이템 찾기 (총 합 계산용)
  List<StockItem> _findAllMatchingStockItems(String itemName, List<StockItem> stockItems) {
    final parsed = _parseNameAndQuantity(itemName);
    final cleanName = (parsed['name'] as String).toLowerCase().trim();
    final matchingItems = <StockItem>[];
    
    for (final stockItem in stockItems) {
      final stockName = stockItem.name.toLowerCase().trim();
      if (stockName == cleanName || 
          stockName.contains(cleanName) || 
          cleanName.contains(stockName)) {
        matchingItems.add(stockItem);
      }
    }
    return matchingItems;
  }

  @override
  Widget build(BuildContext context) {
    // 쿼리 파라미터에서 카테고리 가져오기 (없으면 기본값 유지)
    final category = GoRouterState.of(context).uri.queryParameters['category'];
    if (category != null && category != _selectedCategory) {
      // 카테고리가 변경되었으면 상태 업데이트
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCategory = category;
          });
        }
      });
    }
    
    final shoppingListAsync = ref.watch(shoppingListProvider);

    return AppScaffold(
      title: const Text('ショッピングリスト'),
      leading: IconButton(
        icon: const Icon(Icons.list),
        onPressed: () {
          context.go('/settings');
        },
      ),
      body: Column(
        children: [
          // セグメントコントロール
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: _CategorySegment(
                    label: '冷蔵庫',
                    isSelected: _selectedCategory == 'fridge',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'fridge';
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CategorySegment(
                    label: '備蓄品',
                    isSelected: _selectedCategory == 'stock',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'stock';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // 쇼핑 리스트 카드
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColorSchemes.light.outline,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                      // 헤더 (제목 + 추가 버튼)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '買い物リスト',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Semantics(
                              label: '항목 추가',
                              button: true,
                              child: GestureDetector(
                                onTap: () async {
                                final item = await showDialog<ShoppingListItem>(
                                  context: context,
                                  builder: (context) => AddShoppingItemDialog(
                                    category: _selectedCategory,
                                  ),
                                );
                                if (item != null && context.mounted) {
                                  // 재고 확인하여 자동 체크
                                  final itemWithAutoCheck = await _checkStockAndAutoComplete(
                                    ref,
                                    item,
                                    _selectedCategory,
                                  );
                                  await ref
                                      .read(shoppingListProvider.notifier)
                                      .addItem(itemWithAutoCheck);
                                  if (context.mounted) {
                                    final message = itemWithAutoCheck.isCompleted
                                        ? '${item.name}を追加しました（在庫が十分なため自動で完了しました）'
                                        : '${item.name}を追加しました';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColorSchemes.light.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // リスト項目
                      Expanded(
                        child: shoppingListAsync.when(
                          data: (items) {
                            final filteredItems = items
                                .where((item) => item.category == _selectedCategory)
                                .toList();
                            
                            return filteredItems.isEmpty
                                ? Center(
                                    child: Text(
                                      'リストが空です',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount: filteredItems.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      return _ShoppingListItemTile(
                                        item: item,
                                        category: _selectedCategory,
                                        onTap: () async {
                                          final updatedItem = await showDialog<ShoppingListItem>(
                                            context: context,
                                            builder: (context) => EditShoppingItemDialog(
                                              item: item,
                                            ),
                                          );
                                          if (updatedItem != null && context.mounted) {
                                            await ref
                                                .read(shoppingListProvider.notifier)
                                                .updateItem(updatedItem);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${updatedItem.name}を更新しました'),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        onToggle: () async {
                                          await ref
                                              .read(shoppingListProvider.notifier)
                                              .toggleItem(item.id);
                                        },
                                        onDelete: () async {
                                          await ref
                                              .read(shoppingListProvider.notifier)
                                              .deleteItem(item.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('${item.name}を削除しました'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
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
                                  size: 48,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'データの読み込みに失敗しました',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 예상 총액 및 전체 완료/미완료 버튼
                      shoppingListAsync.when(
                        data: (items) {
                          final filteredItems = items
                              .where((item) => item.category == _selectedCategory)
                              .toList();
                          
                          if (filteredItems.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          // 예상 총액 계산
                          int totalEstimatedPrice = 0;
                          for (final item in filteredItems) {
                            if (item.estimatedPrice != null) {
                              final parsed = _parseNameAndQuantity(item.name);
                              final quantity = parsed['quantity'] as int;
                              totalEstimatedPrice += item.estimatedPrice! * quantity;
                            }
                          }

                          return Column(
                            children: [
                              const Divider(height: 1),
                              // 예상 총액 표시
                              if (totalEstimatedPrice > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  color: AppColorSchemes.light.surfaceContainerHighest,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '予想合計金額',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '¥${totalEstimatedPrice.toString().replaceAllMapped(
                                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                                          (Match m) => '${m[1]},',
                                        )}',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColorSchemes.light.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (totalEstimatedPrice > 0)
                                const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          // 현재 카테고리의 아이템만 완료 처리
                                          final currentItems = ref.read(shoppingListProvider).value ?? [];
                                          final categoryItems = currentItems
                                              .where((item) => item.category == _selectedCategory)
                                              .toList();
                                          
                                          for (final item in categoryItems) {
                                            if (!item.isCompleted) {
                                              await ref
                                                  .read(shoppingListProvider.notifier)
                                                  .toggleItem(item.id);
                                            }
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade700,
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('全て完了'),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          // 현재 카테고리의 아이템만 미완료 처리
                                          final currentItems = ref.read(shoppingListProvider).value ?? [];
                                          final categoryItems = currentItems
                                              .where((item) => item.category == _selectedCategory)
                                              .toList();
                                          
                                          for (final item in categoryItems) {
                                            if (item.isCompleted) {
                                              await ref
                                                  .read(shoppingListProvider.notifier)
                                                  .toggleItem(item.id);
                                            }
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade700,
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('全て未完了'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
    );
  }
}

class _CategorySegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategorySegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColorSchemes.light.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColorSchemes.light.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShoppingListItemTile extends ConsumerWidget {
  final ShoppingListItem item;
  final String category;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ShoppingListItemTile({
    required this.item,
    required this.category,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });


  /// 냉장고와 재고 모두 확인하여 총 합 계산
  Widget? _buildSubtitle(ShoppingListItem item, WidgetRef ref) {
    final parsed = _parseNameAndQuantity(item.name);
    final quantity = parsed['quantity'] as int;
    final hasQuantity = quantity > 1;
    final hasPrice = item.estimatedPrice != null;

    // 냉장고와 재고 모두 확인
    final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
    final stockItemsAsync = ref.watch(stockItemsProvider);

    return fridgeItemsAsync.when(
      data: (fridgeItems) {
        return stockItemsAsync.when(
          data: (stockItems) {
            // 냉장고와 재고 모두에서 매칭되는 아이템 찾기
            final matchingFridgeItems = _findAllMatchingFridgeItemsForDisplay(item.name, fridgeItems);
            final matchingStockItems = _findAllMatchingStockItemsForDisplay(item.name, stockItems);

            // 총 재고 계산
            int totalStock = 0;
            int? maxTargetQty;

            for (final fridgeItem in matchingFridgeItems) {
              totalStock += fridgeItem.quantity;
              final targetQty = fridgeItem.targetQuantity ?? 5;
              if (maxTargetQty == null || targetQty > maxTargetQty) {
                maxTargetQty = targetQty;
              }
            }

            for (final stockItem in matchingStockItems) {
              totalStock += stockItem.quantity;
              final targetQty = stockItem.targetQuantity ?? 5;
              if (maxTargetQty == null || targetQty > maxTargetQty) {
                maxTargetQty = targetQty;
              }
            }

            bool isLowStock = false;
            String? stockInfo;

            // 매칭되는 아이템이 있는 경우
            if (matchingFridgeItems.isNotEmpty || matchingStockItems.isNotEmpty) {
              final targetQty = maxTargetQty ?? 5;
              isLowStock = totalStock < targetQty;
              stockInfo = '在庫: $totalStock/$targetQty';
            } else {
              // 매칭되는 아이템이 없는 경우 (신규 등록 제품)
              // 쇼핑 리스트 아이템의 수량을 목표 수량으로 사용
              final targetQty = quantity;
              isLowStock = true; // 재고가 없으므로 항상 부족
              stockInfo = '在庫: 0/$targetQty';
            }

            final List<String> parts = [];
            if (hasQuantity) {
              parts.add('数量: $quantity');
            }
            if (hasPrice) {
              parts.add('予想:¥${item.estimatedPrice}');
            }
            // stockInfo는 항상 설정되므로 null 체크 불필요
            parts.add(stockInfo);

            if (parts.isEmpty) {
              return null;
            }

            return Row(
              children: [
                Expanded(
                  child: Text(
                    parts.join(' | '),
                    style: TextStyle(
                      color: isLowStock ? Colors.orange.shade700 : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isLowStock)
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
              ],
            );
          },
          loading: () {
            final List<String> parts = [];
            if (hasQuantity) {
              parts.add('数量: $quantity');
            }
            if (hasPrice) {
              parts.add('予想:¥${item.estimatedPrice}');
            }
            if (parts.isEmpty) {
              return null;
            }
            return Text(
              parts.join(' | '),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            );
          },
          error: (_, __) {
            final List<String> parts = [];
            if (hasQuantity) {
              parts.add('数量: $quantity');
            }
            if (hasPrice) {
              parts.add('予想:¥${item.estimatedPrice}');
            }
            if (parts.isEmpty) {
              return null;
            }
            return Text(
              parts.join(' | '),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            );
          },
        );
      },
      loading: () {
        final List<String> parts = [];
        if (hasQuantity) {
          parts.add('数量: $quantity');
        }
        if (hasPrice) {
          parts.add('予想:¥${item.estimatedPrice}');
        }
        if (parts.isEmpty) {
          return null;
        }
        return Text(
          parts.join(' | '),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        );
      },
      error: (_, __) {
        final List<String> parts = [];
        if (hasQuantity) {
          parts.add('数量: $quantity');
        }
        if (hasPrice) {
          parts.add('予想:¥${item.estimatedPrice}');
        }
        if (parts.isEmpty) {
          return null;
        }
        return Text(
          parts.join(' | '),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        );
      },
    );
  }

  /// 쇼핑 리스트 아이템 이름과 매칭되는 모든 냉장고 아이템 찾기 (표시용)
  List<FridgeItem> _findAllMatchingFridgeItemsForDisplay(String itemName, List<FridgeItem> fridgeItems) {
    final parsed = _parseNameAndQuantity(itemName);
    final cleanName = (parsed['name'] as String).toLowerCase().trim();
    final matchingItems = <FridgeItem>[];
    
    for (final fridgeItem in fridgeItems) {
      final fridgeName = fridgeItem.name.toLowerCase().trim();
      if (fridgeName == cleanName || 
          fridgeName.contains(cleanName) || 
          cleanName.contains(fridgeName)) {
        matchingItems.add(fridgeItem);
      }
    }
    return matchingItems;
  }

  /// 쇼핑 리스트 아이템 이름과 매칭되는 모든 재고 아이템 찾기 (표시용)
  List<StockItem> _findAllMatchingStockItemsForDisplay(String itemName, List<StockItem> stockItems) {
    final parsed = _parseNameAndQuantity(itemName);
    final cleanName = (parsed['name'] as String).toLowerCase().trim();
    final matchingItems = <StockItem>[];
    
    for (final stockItem in stockItems) {
      final stockName = stockItem.name.toLowerCase().trim();
      if (stockName == cleanName || 
          stockName.contains(cleanName) || 
          cleanName.contains(stockName)) {
        matchingItems.add(stockItem);
      }
    }
    return matchingItems;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: Semantics(
        label: item.isCompleted ? '${item.name} 완료됨' : '${item.name} 미완료',
        child: Checkbox(
          value: item.isCompleted,
          onChanged: (_) => onToggle(),
          activeColor: AppColorSchemes.light.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      title: Semantics(
        label: item.name,
        child: Text(
          item.name,
          style: TextStyle(
            decoration: item.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: item.isCompleted ? Colors.grey.shade500 : Colors.black87,
          ),
        ),
      ),
      subtitle: _buildSubtitle(item, ref),
      trailing: Semantics(
        label: '${item.name} 삭제',
        button: true,
        child: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
          iconSize: 20,
        ),
      ),
      onTap: onTap,
    );
  }
}
