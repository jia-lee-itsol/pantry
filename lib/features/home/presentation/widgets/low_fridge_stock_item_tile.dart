import 'package:flutter/material.dart';

import '../../../fridge/domain/entities/fridge_item.dart';

class LowFridgeStockItemTile extends StatelessWidget {
  final FridgeItem item;

  const LowFridgeStockItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final targetQty = item.targetQuantity ?? 5;
    final isLowStock = item.quantity < targetQty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          Icons.kitchen_outlined,
          color: Colors.orange.shade700,
          size: 24,
        ),
        title: Text(item.name),
        subtitle: Text(item.category ?? 'その他'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '現在: ${item.quantity}',
                  style: TextStyle(
                    color: isLowStock ? Colors.orange.shade700 : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '目標: $targetQty',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              isLowStock ? Icons.warning_amber_rounded : Icons.check_circle,
              color: isLowStock ? Colors.orange.shade700 : Colors.green,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

