import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';

class EmergencyItemCard extends StatelessWidget {
  final String itemName;
  final String recommendedQuantity;
  final int? currentQuantity;
  final bool isEssential;

  const EmergencyItemCard({
    super.key,
    required this.itemName,
    required this.recommendedQuantity,
    this.currentQuantity,
    this.isEssential = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasItem = currentQuantity != null && currentQuantity! > 0;
    final isLow = currentQuantity != null && currentQuantity! < 3;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isEssential
          ? Colors.red.shade50
          : hasItem
              ? Colors.green.shade50
              : Colors.grey.shade50,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: hasItem
                ? (isLow ? Colors.orange.shade100 : Colors.green.shade100)
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasItem ? (isLow ? Icons.warning_amber : Icons.check_circle) : Icons.error_outline,
            color: hasItem
                ? (isLow ? Colors.orange.shade700 : Colors.green.shade700)
                : Colors.grey.shade600,
            size: 24,
          ),
        ),
        title: Text(
          itemName,
          style: TextStyle(
            fontWeight: isEssential ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('推奨: $recommendedQuantity'),
        trailing: currentQuantity != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isLow
                      ? Colors.orange.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '所持: $currentQuantity',
                  style: TextStyle(
                    color: isLow
                        ? Colors.orange.shade900
                        : Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : Text(
                '未所持',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}

