import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/fridge_item.dart';
import '../providers/fridge_provider.dart';
import 'edit_fridge_item_bottom_sheet.dart';

class FridgeItemRow extends ConsumerWidget {
  final FridgeItem item;

  const FridgeItemRow({
    super.key,
    required this.item,
  });

  Future<bool> _handleConsume(BuildContext context, WidgetRef ref) async {
    final newQuantity = item.quantity - 1;

    if (newQuantity <= 0) {
      try {
        await ref.read(fridgeRepositoryProvider).deleteFridgeItem(item.id);
        ref.invalidate(fridgeItemsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name}を消費して削除しました。')),
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('消費処理失敗: $e')),
          );
        }
        return false;
      }
    } else {
      try {
        final updatedItem = item.copyWith(
          quantity: newQuantity,
          updatedAt: DateTime.now(),
        );
        await ref.read(fridgeRepositoryProvider).updateFridgeItem(updatedItem);
        ref.invalidate(fridgeItemsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} 数量: ${item.quantity} → $newQuantity'),
            ),
          );
        }
        return false;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('消費処理失敗: $e')),
          );
        }
        return false;
      }
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('${item.name}を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(fridgeRepositoryProvider).deleteFridgeItem(item.id);
        ref.invalidate(fridgeItemsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('冷蔵庫アイテムを削除しました。')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除失敗: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        confirmDismiss: (_) => _handleConsume(context, ref),
        child: _buildItemContent(context, ref),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            '消費',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemContent(BuildContext context, WidgetRef ref) {
    return Semantics(
      label:
          '${item.name}, 수량: ${item.quantity}, 유통기한: ${item.expiryDate.year}년 ${item.expiryDate.month}월 ${item.expiryDate.day}일',
      button: true,
      child: InkWell(
        onTap: () => _showEditBottomSheet(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(child: _buildItemInfo(context)),
              if (item.isFrozen) _buildFrozenBadge(),
              _buildDeleteButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditFridgeItemBottomSheet(item: item),
    );
  }

  Widget _buildItemInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(item.name, style: Theme.of(context).textTheme.bodyLarge),
            if (item.isFrozen) ...[
              const SizedBox(width: 8),
              Icon(Icons.ac_unit, color: Colors.blue.shade400, size: 18),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '数量: ${item.quantity}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade600),
        ),
        if (!item.isFrozen) ...[
          const SizedBox(height: 2),
          Text(
            '賞味期限: ${item.expiryDate.year}/${item.expiryDate.month}/${item.expiryDate.day}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  Widget _buildFrozenBadge() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ac_unit, color: Colors.blue.shade400, size: 20),
          const SizedBox(width: 4),
          Text(
            '冷凍',
            style: TextStyle(
              color: Colors.blue.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: '${item.name} 삭제',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.delete_outline),
        color: Colors.grey.shade600,
        onPressed: () => _handleDelete(context, ref),
      ),
    );
  }
}
