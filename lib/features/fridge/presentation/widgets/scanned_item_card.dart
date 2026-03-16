import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';
import '../../../ocr/domain/entities/receipt_item.dart';

class ScannedItemCard extends StatelessWidget {
  final ReceiptItem item;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const ScannedItemCard({
    super.key,
    required this.item,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '数量: ${item.quantity}  |  ${item.price.toStringAsFixed(0)}円',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward, color: Colors.blue),
              onPressed: onApply,
              tooltip: '下のフォームに適用',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
              tooltip: '削除',
            ),
          ],
        ),
      ),
    );
  }
}
