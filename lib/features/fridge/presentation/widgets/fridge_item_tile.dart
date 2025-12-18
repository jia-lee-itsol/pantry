import 'package:flutter/material.dart';

import '../../domain/entities/fridge_item.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;

class FridgeItemTile extends StatelessWidget {
  final FridgeItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FridgeItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = item.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
    final isExpired = daysUntilExpiry < 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      title: Text(item.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('数量: ${item.quantity}'),
          Text(
            '消費期限: ${app_date_utils.DateUtils.formatDate(item.expiryDate)}',
            style: TextStyle(
              color: isExpired
                  ? Theme.of(context).colorScheme.error
                  : isExpiringSoon
                      ? Theme.of(context).colorScheme.tertiary
                      : null,
            ),
          ),
        ],
      ),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            )
          : null,
      onTap: onTap,
    );
  }
}

