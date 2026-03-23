import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/spacing.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../widgets/near_expiry_item_tile.dart';

// ============================================
// Near Expiry List Page
// ============================================

/// Full list page displaying all items expiring within 7 days.
///
/// This page shows a complete, scrollable list of refrigerator items
/// that are approaching their expiration date. It includes:
/// - All items expiring within the next 7 days
/// - Excludes frozen items (they don't expire while frozen)
/// - Sorted by expiry date (soonest first)
/// - Quick actions (Consume/Freeze) for each item
/// - Undo functionality for consumed items
///
/// Features:
/// - Empty state when no items are expiring
/// - Loading and error states
/// - Interactive tiles with consume and freeze actions
/// - Snackbar feedback with undo option for deletions
///
/// This page is accessed from the "See more" button on the
/// Near Expiry Section widget on the home page.
class NearExpiryListPage extends ConsumerWidget {
  const NearExpiryListPage({super.key});

  /// Builds the near expiry list page widget.
  ///
  /// Filters items to show only those expiring within 7 days,
  /// excluding frozen items, and provides action buttons for each.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: Widget ref for accessing providers
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgeItemsAsync = ref.watch(fridgeItemsProvider);

    return AppScaffold(
      title: const Text('期限間近の商品'),
      body: fridgeItemsAsync.when(
        data: (items) {
          final nearExpiryItems = items.where((item) {
            // 냉동 아이템은 제외
            if (item.isFrozen) {
              return false;
            }
            final daysUntilExpiry = item.expiryDate
                .difference(DateTime.now())
                .inDays;
            return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
          }).toList()..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

          if (nearExpiryItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '期限間近の商品はありません。',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'すべての商品が安全です。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: nearExpiryItems.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = nearExpiryItems[index];
              return NearExpiryItemTile(
                item: item,
                onConsume: () async {
                  try {
                    // 복원을 위해 아이템 정보 저장
                    final itemToRestore = item;
                    
                    await ref
                        .read(fridgeRepositoryProvider)
                        .deleteFridgeItem(item.id);
                    ref.invalidate(fridgeItemsProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.name}を消費済みにしました。'),
                          action: SnackBarAction(
                            label: '取消',
                            onPressed: () async {
                              try {
                                // 아이템 복원
                                await ref
                                    .read(fridgeRepositoryProvider)
                                    .addFridgeItem(itemToRestore);
                                ref.invalidate(fridgeItemsProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${itemToRestore.name}を復元しました。'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('復元に失敗しました: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('処理失敗: $e')));
                    }
                  }
                },
                onFreeze: () async {
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
                    await ref
                        .read(fridgeRepositoryProvider)
                        .updateFridgeItem(updatedItem);
                    ref.invalidate(fridgeItemsProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name}を冷凍しました。')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('処理失敗: $e')));
                    }
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: AppSpacing.md),
              Text(
                'データを読み込めませんでした。',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
