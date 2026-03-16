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
import '../widgets/category_segment.dart';
import '../widgets/shopping_list_item_tile.dart';
import '../widgets/shopping_list_footer.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

class ListPage extends ConsumerStatefulWidget {
  const ListPage({super.key});

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  String _selectedCategory = 'fridge';

  Future<ShoppingListItem> _checkStockAndAutoComplete(
    WidgetRef ref,
    ShoppingListItem item,
    String category,
  ) async {
    final parsed = parseNameAndQuantity(item.name);
    final neededQuantity = parsed['quantity'] as int;

    int totalStock = 0;

    try {
      final fridgeItems = await ref.read(fridgeItemsProvider.future);
      final matchingFridgeItems =
          _findAllMatchingFridgeItems(item.name, fridgeItems);
      for (final fridgeItem in matchingFridgeItems) {
        totalStock += fridgeItem.quantity;
      }

      final stockItems = await ref.read(stockItemsProvider.future);
      final matchingStockItems =
          _findAllMatchingStockItems(item.name, stockItems);
      for (final stockItem in matchingStockItems) {
        totalStock += stockItem.quantity;
      }
    } catch (e) {
      totalStock = 0;
    }

    final hasEnoughStock = totalStock >= neededQuantity;
    return item.copyWith(isCompleted: hasEnoughStock);
  }

  List<FridgeItem> _findAllMatchingFridgeItems(
      String itemName, List<FridgeItem> fridgeItems) {
    final parsed = parseNameAndQuantity(itemName);
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

  List<StockItem> _findAllMatchingStockItems(
      String itemName, List<StockItem> stockItems) {
    final parsed = parseNameAndQuantity(itemName);
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
    final category =
        GoRouterState.of(context).uri.queryParameters['category'];
    if (category != null && category != _selectedCategory) {
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
          _buildCategorySelector(),
          Expanded(
            child: _buildShoppingListCard(shoppingListAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: CategorySegment(
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
            child: CategorySegment(
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
    );
  }

  Widget _buildShoppingListCard(
      AsyncValue<List<ShoppingListItem>> shoppingListAsync) {
    return Card(
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
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: _buildListContent(shoppingListAsync),
          ),
          shoppingListAsync.when(
            data: (items) => ShoppingListFooter(
              items: items,
              selectedCategory: _selectedCategory,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              onTap: () => _showAddItemDialog(),
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
    );
  }

  Future<void> _showAddItemDialog() async {
    final item = await showDialog<ShoppingListItem>(
      context: context,
      builder: (context) => AddShoppingItemDialog(
        category: _selectedCategory,
      ),
    );
    if (item != null && mounted) {
      final itemWithAutoCheck = await _checkStockAndAutoComplete(
        ref,
        item,
        _selectedCategory,
      );
      await ref.read(shoppingListProvider.notifier).addItem(itemWithAutoCheck);
      if (mounted) {
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
  }

  Widget _buildListContent(AsyncValue<List<ShoppingListItem>> shoppingListAsync) {
    return shoppingListAsync.when(
      data: (items) {
        final filteredItems =
            items.where((item) => item.category == _selectedCategory).toList();

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
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ShoppingListItemTile(
                    item: item,
                    category: _selectedCategory,
                    onTap: () => _showEditItemDialog(item),
                    onToggle: () async {
                      await ref
                          .read(shoppingListProvider.notifier)
                          .toggleItem(item.id);
                    },
                    onDelete: () => _deleteItem(item),
                  );
                },
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(),
    );
  }

  Future<void> _showEditItemDialog(ShoppingListItem item) async {
    final updatedItem = await showDialog<ShoppingListItem>(
      context: context,
      builder: (context) => EditShoppingItemDialog(item: item),
    );
    if (updatedItem != null && mounted) {
      await ref.read(shoppingListProvider.notifier).updateItem(updatedItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedItem.name}を更新しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(ShoppingListItem item) async {
    await ref.read(shoppingListProvider.notifier).deleteItem(item.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name}を削除しました'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildErrorState() {
    return Center(
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
    );
  }
}
