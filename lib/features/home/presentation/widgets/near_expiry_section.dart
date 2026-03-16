import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../providers/home_provider.dart';
import '../pages/near_expiry_list_page.dart';
import 'near_expiry_item_tile.dart';

class NearExpirySection extends ConsumerWidget {
  final AsyncValue<List<FridgeItem>> fridgeItemsAsync;

  const NearExpirySection({
    super.key,
    required this.fridgeItemsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppSpacing.md),
        _buildContent(context, ref),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '期限間近商品',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        fridgeItemsAsync.when(
          data: (items) {
            final nearExpiryCount = _getNearExpiryItems(items).length;
            if (nearExpiryCount == 0) {
              return const SizedBox.shrink();
            }
            return TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NearExpiryListPage(),
                  ),
                );
              },
              child: const Text('もっと見る'),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return fridgeItemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(context);
        }

        final nearExpiryItems = _getNearExpiryItems(items)
          ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

        if (nearExpiryItems.isEmpty) {
          return _buildNoExpiryState(context);
        }

        return Column(
          children: nearExpiryItems
              .take(5)
              .map(
                (item) => NearExpiryItemTile(
                  item: item,
                  onConsume: () => _handleConsume(context, ref, item),
                  onFreeze: () => _handleFreeze(context, ref, item),
                ),
              )
              .toList(),
        );
      },
      loading: () => _buildLoadingState(context),
      error: (_, _) => _buildErrorState(context),
    );
  }

  List<FridgeItem> _getNearExpiryItems(List<FridgeItem> items) {
    return items.where((item) {
      if (item.isFrozen) return false;
      final daysUntilExpiry =
          item.expiryDate.difference(DateTime.now()).inDays;
      return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
    }).toList();
  }

  Future<void> _handleConsume(
      BuildContext context, WidgetRef ref, FridgeItem item) async {
    try {
      await ref.read(fridgeRepositoryProvider).deleteFridgeItem(item.id);
      ref.invalidate(fridgeItemsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name}を消費完了しました。')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('処理失敗: $e')),
        );
      }
    }
  }

  Future<void> _handleFreeze(
      BuildContext context, WidgetRef ref, FridgeItem item) async {
    try {
      final updatedItem = FridgeItem(
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        category: item.category,
        expiryDate: item.expiryDate,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
        isFrozen: true,
      );
      await ref.read(fridgeRepositoryProvider).updateFridgeItem(updatedItem);
      ref.invalidate(fridgeItemsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name}を冷凍処理しました。')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('処理失敗: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '期限間近商品がありません。',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '冷蔵庫に商品を追加してみてください。',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoExpiryState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Colors.green.shade300,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '期限間近商品がありません。',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'すべての商品が安全です。',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'データを読み込めません。',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
