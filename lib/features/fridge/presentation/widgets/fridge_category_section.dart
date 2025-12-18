import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/fridge_item.dart';
import 'fridge_item_tile.dart';

class FridgeCategorySection extends StatelessWidget {
  final String category;
  final List<FridgeItem> items;
  final Function(FridgeItem)? onItemTap;
  final Function(FridgeItem)? onItemDelete;

  const FridgeCategorySection({
    super.key,
    required this.category,
    required this.items,
    this.onItemTap,
    this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const Spacer(),
                Text(
                  '${items.length}個',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          // 아이템 리스트
          ...items.map((item) => FridgeItemTile(
                item: item,
                onTap: onItemTap != null ? () => onItemTap!(item) : null,
                onDelete: onItemDelete != null
                    ? () => onItemDelete!(item)
                    : null,
              )),
        ],
      ),
    );
  }
}

