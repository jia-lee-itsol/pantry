import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

// ============================================
// Helper Functions
// ============================================

/// Parses item name to extract product name and quantity.
///
/// Supports the format "Product Name (数量: X)" where X is the quantity.
/// If no quantity is found, defaults to quantity 1.
///
/// Examples:
/// - "商品名 (数量: 3)" -> {name: "商品名", quantity: 3}
/// - "商品名" -> {name: "商品名", quantity: 1}
///
/// Parameters:
/// - [name]: The full item name to parse
///
/// Returns a Map with 'name' (String) and 'quantity' (int) keys.
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

// ============================================
// Shopping List Item Tile Widget
// ============================================

/// List tile widget for displaying a shopping list item with stock information.
///
/// This widget provides a rich display of shopping list items including:
/// - Checkbox for marking items complete
/// - Item name with strikethrough when completed
/// - Quantity and price information
/// - Real-time stock status from fridge and stock inventories
/// - Low stock warnings with icon
/// - Delete button
///
/// Key features:
/// - Smart stock matching: Fuzzy matches item name with inventory
/// - Stock status display: Shows current/target quantities
/// - Low stock alerts: Highlights items below target quantity
/// - Interactive: Tap to edit, checkbox to toggle, button to delete
///
/// The tile integrates with both fridge and stock providers to show
/// comprehensive inventory information and warn users about low stock.
class ShoppingListItemTile extends ConsumerWidget {
  /// The shopping list item to display
  final ShoppingListItem item;

  /// Category of the item ('fridge' or 'stock')
  final String category;

  /// Callback when tile is tapped (for editing)
  final VoidCallback onTap;

  /// Callback when checkbox is toggled
  final VoidCallback onToggle;

  /// Callback when delete button is pressed
  final VoidCallback onDelete;

  /// Creates a [ShoppingListItemTile].
  ///
  /// All callbacks are required to ensure proper functionality.
  const ShoppingListItemTile({
    super.key,
    required this.item,
    required this.category,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  // ============================================
  // Stock Matching Methods
  // ============================================

  /// Finds all fridge items matching the shopping list item name.
  ///
  /// Uses fuzzy matching where names are compared case-insensitively
  /// and matches if either name contains the other.
  ///
  /// Parameters:
  /// - [itemName]: The shopping list item name
  /// - [fridgeItems]: List of available fridge items
  ///
  /// Returns a list of matching [FridgeItem]s.
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

  /// Finds all stock items matching the shopping list item name.
  ///
  /// Uses fuzzy matching where names are compared case-insensitively
  /// and matches if either name contains the other.
  ///
  /// Parameters:
  /// - [itemName]: The shopping list item name
  /// - [stockItems]: List of available stock items
  ///
  /// Returns a list of matching [StockItem]s.
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

  // ============================================
  // UI Building Methods
  // ============================================

  /// Builds the subtitle widget showing quantity, price, and stock info.
  ///
  /// This method:
  /// 1. Parses quantity from item name
  /// 2. Checks both fridge and stock for matching items
  /// 3. Calculates total available stock
  /// 4. Determines if stock is low (below target quantity)
  /// 5. Builds a formatted subtitle with all information
  ///
  /// The subtitle includes:
  /// - Quantity (if > 1)
  /// - Estimated price (if set)
  /// - Stock status (current/target)
  /// - Warning icon (if low stock)
  ///
  /// Parameters:
  /// - [item]: The shopping list item
  /// - [ref]: Widget ref for accessing providers
  ///
  /// Returns a Widget displaying the subtitle, or null if no info to show.
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

  /// Builds a basic subtitle without stock information.
  ///
  /// Used as a fallback when stock data is loading or unavailable.
  /// Shows only quantity and price information.
  ///
  /// Parameters:
  /// - [hasQuantity]: Whether quantity > 1
  /// - [quantity]: The quantity value
  /// - [hasPrice]: Whether estimated price is set
  ///
  /// Returns a Text widget with formatted info, or null if nothing to show.
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

  /// Builds the shopping list item tile widget.
  ///
  /// Creates a ListTile with:
  /// - Checkbox for completion status
  /// - Item name (with strikethrough when complete)
  /// - Subtitle with quantity, price, and stock info
  /// - Delete button
  /// - Tap handler for editing
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: Widget ref for accessing providers
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
