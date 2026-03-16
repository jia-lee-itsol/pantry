import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// name에서 상품명과 수량 파싱
Map<String, dynamic> parseNameAndQuantity(String name) {
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

class ShoppingListItemTile extends ConsumerWidget {
  final ShoppingListItem item;
  final String category;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ShoppingListItemTile({
    super.key,
    required this.item,
    required this.category,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

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

  Widget? _buildSubtitle(ShoppingListItem item, WidgetRef ref) {
    final parsed = parseNameAndQuantity(item.name);
    final quantity = parsed['quantity'] as int;
    final hasQuantity = quantity > 1;
    final hasPrice = item.estimatedPrice != null;

    final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
    final stockItemsAsync = ref.watch(stockItemsProvider);

    return fridgeItemsAsync.when(
      data: (fridgeItems) {
        return stockItemsAsync.when(
          data: (stockItems) {
            final matchingFridgeItems =
                _findAllMatchingFridgeItems(item.name, fridgeItems);
            final matchingStockItems =
                _findAllMatchingStockItems(item.name, stockItems);

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
            String stockInfo;

            if (matchingFridgeItems.isNotEmpty ||
                matchingStockItems.isNotEmpty) {
              final targetQty = maxTargetQty ?? 5;
              isLowStock = totalStock < targetQty;
              stockInfo = '在庫: $totalStock/$targetQty';
            } else {
              final targetQty = quantity;
              isLowStock = true;
              stockInfo = '在庫: 0/$targetQty';
            }

            final List<String> parts = [];
            if (hasQuantity) {
              parts.add('数量: $quantity');
            }
            if (hasPrice) {
              parts.add('予想:¥${item.estimatedPrice}');
            }
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
                      color: isLowStock
                          ? Colors.orange.shade700
                          : Colors.grey.shade600,
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
          loading: () => _buildBasicSubtitle(hasQuantity, quantity, hasPrice),
          error: (_, _) => _buildBasicSubtitle(hasQuantity, quantity, hasPrice),
        );
      },
      loading: () => _buildBasicSubtitle(hasQuantity, quantity, hasPrice),
      error: (_, _) => _buildBasicSubtitle(hasQuantity, quantity, hasPrice),
    );
  }

  Widget? _buildBasicSubtitle(bool hasQuantity, int quantity, bool hasPrice) {
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
