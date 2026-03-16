import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/color_schemes.dart';
import '../../../../core/design/spacing.dart';
import '../../domain/entities/shopping_list_item.dart';
import '../providers/shopping_list_provider.dart';
import 'shopping_list_item_tile.dart';

class ShoppingListFooter extends ConsumerWidget {
  final List<ShoppingListItem> items;
  final String selectedCategory;

  const ShoppingListFooter({
    super.key,
    required this.items,
    required this.selectedCategory,
  });

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
