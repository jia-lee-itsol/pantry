import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';

class LowStockAlertCard extends StatelessWidget {
  final int count;

  const LowStockAlertCard({
    super.key,
    required this.count,
  });

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

