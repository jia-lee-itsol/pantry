import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../fridge/domain/entities/fridge_item.dart';

class LowFridgeStockAlert extends StatelessWidget {
  final List<FridgeItem> lowStockItems;

  const LowFridgeStockAlert({
    super.key,
    required this.lowStockItems,
  });

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
