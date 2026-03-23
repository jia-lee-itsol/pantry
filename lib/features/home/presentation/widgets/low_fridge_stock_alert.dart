import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../fridge/domain/entities/fridge_item.dart';

// ============================================
// Low Fridge Stock Alert Widget
// ============================================

/// Alert card widget for displaying low refrigerator stock items.
///
/// This widget shows an orange alert when there are fridge items
/// that have fallen below their target quantity. It includes:
/// - Kitchen icon in orange
/// - Count of low fridge stock items
/// - Tap functionality to navigate to the detailed low fridge stock page
///
/// The card automatically hides when the list is empty, showing only
/// when user action is needed to restock refrigerator items.
///
/// Visual design:
/// - Orange color scheme to indicate warning (not critical)
/// - Rounded corners with border
/// - Tappable with visual feedback
class LowFridgeStockAlert extends StatelessWidget {
  /// List of fridge items with low stock
  final List<FridgeItem> lowStockItems;

  /// Creates a [LowFridgeStockAlert].
  ///
  /// Parameters:
  /// - [lowStockItems]: List of items below target quantity (required)
  const LowFridgeStockAlert({
    super.key,
    required this.lowStockItems,
  });

  /// Builds the low fridge stock alert card widget.
  ///
  /// Returns an empty widget if list is empty, otherwise displays
  /// an orange alert card with stock information and navigation.
  ///
  /// Parameters:
  /// - [context]: The build context
  @override
  Widget build(BuildContext context) {
    if (lowStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        context.go('/low-fridge-stock');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.kitchen_outlined,
              color: Colors.orange.shade700,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '冷蔵庫在庫不足の商品が${lowStockItems.length}個あります',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.orange.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
