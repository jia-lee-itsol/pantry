import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../providers/shopping_list_provider.dart';
import 'shopping_list_item_tile.dart';

// ============================================
// Shopping List Footer Widget
// ============================================

/// Footer widget for the shopping list showing total price and actions.
///
/// This widget appears at the bottom of the shopping list and provides:
/// - Total estimated price calculation (if any items have prices)
/// - Bulk action buttons:
///   - "Mark All Complete": Marks all incomplete items as complete
///   - "Mark All Incomplete": Marks all complete items as incomplete
///
/// Features:
/// - Automatically calculates total based on item prices and quantities
/// - Formats currency with thousand separators
/// - Only shows for items in the selected category
/// - Hides when category has no items
///
/// Responsibilities:
/// - Display aggregated price information
/// - Provide bulk operations for list management
/// - Filter items by selected category
class ShoppingListFooter extends ConsumerWidget {
  /// Complete list of shopping list items
  final List<ShoppingListItem> items;

  /// Currently selected category to filter by
  final String selectedCategory;

  /// Creates a [ShoppingListFooter].
  ///
  /// Parameters:
  /// - [items]: All shopping list items (required)
  /// - [selectedCategory]: The category to display footer for (required)
  const ShoppingListFooter({
    super.key,
    required this.items,
    required this.selectedCategory,
  });

  /// Builds the shopping list footer widget.
  ///
  /// Calculates total price and displays action buttons for the
  /// items in the selected category.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: Widget ref for accessing providers
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItems =
        items.where((item) => item.category == selectedCategory).toList();

    if (filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    int totalEstimatedPrice = 0;
    for (final item in filteredItems) {
      if (item.estimatedPrice != null) {
        final parsed = parseNameAndQuantity(item.name);
        final quantity = parsed['quantity'] as int;
        totalEstimatedPrice += item.estimatedPrice! * quantity;
      }
    }

    return Column(
      children: [
        const Divider(height: 1),
        if (totalEstimatedPrice > 0) ...[
          _buildTotalPrice(context, totalEstimatedPrice),
          const Divider(height: 1),
        ],
        _buildActionButtons(context, ref, filteredItems),
      ],
    );
  }

  // ============================================
  // UI Component Builders
  // ============================================

  /// Builds the total price display section.
  ///
  /// Shows the estimated total cost with formatted currency.
  /// Uses thousand separators for better readability.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [totalEstimatedPrice]: The calculated total price
  ///
  /// Returns a Container with the formatted price display.
  Widget _buildTotalPrice(BuildContext context, int totalEstimatedPrice) {
    return Container(
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
    );
  }

  /// Builds the action buttons section.
  ///
  /// Provides two buttons:
  /// - "Mark All Complete": Toggles all incomplete items to complete
  /// - "Mark All Incomplete": Toggles all complete items to incomplete
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: Widget ref for accessing providers
  /// - [categoryItems]: Items in the selected category
  ///
  /// Returns a Row containing the action buttons.
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    List<ShoppingListItem> categoryItems,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
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
                side: BorderSide(color: Colors.grey.shade300),
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
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('全て未完了'),
            ),
          ),
        ],
      ),
    );
  }
}
