import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/receipt_item.dart';

enum StorageType { fridge, stock }

class ReceiptItemCard extends StatelessWidget {
  final ReceiptItem item;
  final StorageType? savedType;
  final VoidCallback onTap;
  final VoidCallback onSaveToFridge;
  final VoidCallback onSaveToStock;

  const ReceiptItemCard({
    super.key,
    required this.item,
    this.savedType,
    required this.onTap,
    required this.onSaveToFridge,
    required this.onSaveToStock,
  });

  bool get isSaved => savedType != null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemInfo(context),
              const SizedBox(height: AppSpacing.sm),
              if (isSaved)
                _buildSavedIndicator()
              else
                _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildBadge(
                    '数量: ${item.quantity}',
                    Colors.blue.shade50,
                    Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    '${item.price.toStringAsFixed(0)}円',
                    Colors.green.shade50,
                    Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          Icons.edit_outlined,
          size: 20,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildBadge(
    String text,
    Color backgroundColor,
    Color textColor, {
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget _buildSavedIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${savedType == StorageType.fridge ? '冷蔵庫' : '備蓄品'}に追加済み',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSaveToFridge,
            icon: const Icon(Icons.kitchen, size: 18),
            label: const Text('冷蔵庫'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              side: BorderSide(color: Colors.blue.shade300),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSaveToStock,
            icon: const Icon(Icons.inventory_2, size: 18),
            label: const Text('備蓄品'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: Colors.orange.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
