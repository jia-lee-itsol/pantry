import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';

// ============================================
// Low Stock Alert Card Widget
// ============================================

/// Alert card widget for displaying low stockpile items.
///
/// This widget shows an orange alert when there are stockpile items
/// that have fallen below their target quantity. It includes:
/// - Inventory icon in orange
/// - Count of low stock items
/// - Tap functionality to navigate to the detailed low stock page
///
/// The card automatically hides when count is 0, showing only
/// when user action is needed to restock items.
///
/// Visual design:
/// - Orange color scheme to indicate warning (not critical)
/// - Rounded corners with border
/// - Tappable with visual feedback
class LowStockAlertCard extends StatelessWidget {
  /// Number of items with low stock
  final int count;

  /// Creates a [LowStockAlertCard].
  ///
  /// Parameters:
  /// - [count]: Number of items below target quantity (required)
  const LowStockAlertCard({
    super.key,
    required this.count,
  });

  /// Builds the low stock alert card widget.
  ///
  /// Returns an empty widget if count is 0, otherwise displays
  /// an orange alert card with stock information and navigation.
  ///
  /// Parameters:
  /// - [context]: The build context
  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        context.push('/low-stock');
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
              Icons.inventory_2_outlined,
              color: Colors.orange.shade700,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '在庫不足の商品が$count個あります',
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

