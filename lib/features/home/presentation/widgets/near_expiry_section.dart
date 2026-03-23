import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../pages/near_expiry_list_page.dart';
import 'near_expiry_item_tile.dart';

// ============================================
// Near Expiry Section Widget
// ============================================

/// Section widget displaying items nearing their expiration date.
///
/// This section appears on the home page and shows:
/// - Header with "See more" button (when items exist)
/// - Up to 5 items expiring within 7 days
/// - Quick actions (Consume/Freeze) for each item
/// - Empty state when no items exist
/// - "No expiring items" state when all items are fresh
///
/// Key features:
/// - Filters out frozen items from the expiry check
/// - Sorts items by expiry date (soonest first)
/// - Provides quick actions without leaving the home page
/// - Shows appropriate loading/error states
///
/// Responsibilities:
/// - Display near-expiry items summary
/// - Enable quick consume/freeze actions
/// - Navigate to full near-expiry list
/// - Show appropriate empty/error states
class NearExpirySection extends ConsumerWidget {
  /// Async value containing fridge items data
  final AsyncValue<List<FridgeItem>> fridgeItemsAsync;

  /// Creates a [NearExpirySection].
  ///
  /// Parameters:
  /// - [fridgeItemsAsync]: Async value with fridge items (required)
  const NearExpirySection({
    super.key,
    required this.fridgeItemsAsync,
  });

  /// Builds the near expiry section widget.
  ///
  /// Displays header, items list, and handles various states
  /// (loading, error, empty).
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: The widget ref for accessing providers
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, ref),
        const SizedBox(height: AppSpacing.md),
        _buildContent(context, ref),
      ],
    );
  }

  // ============================================
  // UI Component Builders
  // ============================================

  /// Builds the section header with title and "See more" button.
  ///
  /// The "See more" button only appears when there are near-expiry items.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: The widget ref
  ///
  /// Returns a Row containing the title and optional button.
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
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
            final nearExpiryCount = _getNearExpiryItems(items, ref).length;
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

  /// Builds the main content area with near-expiry items or appropriate states.
  ///
  /// Handles multiple states:
  /// - Loading: Shows loading indicator
  /// - Error: Shows error message
  /// - Empty: Shows empty state message
  /// - No expiring items: Shows success state
  /// - Has items: Shows up to 5 items with action buttons
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: The widget ref
  ///
  /// Returns the appropriate widget based on current state.
  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return fridgeItemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(context);
        }

        final nearExpiryItems = _getNearExpiryItems(items, ref)
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

  // ============================================
  // Helper Methods
  // ============================================

  /// Gets items that are near expiry (within 7 days).
  ///
  /// This method:
  /// 1. Filters out frozen items (they don't expire while frozen)
  /// 2. Applies the near-expiry use case to find items expiring soon
  ///
  /// Parameters:
  /// - [items]: List of all fridge items
  /// - [ref]: The widget ref for accessing use cases
  ///
  /// Returns a filtered list of near-expiry items.
  List<FridgeItem> _getNearExpiryItems(List<FridgeItem> items, WidgetRef ref) {
    final getNearExpiryUseCase = ref.read(getNearExpiryItemsUseCaseProvider);
    // Filter out frozen items first, then apply near expiry filter
    final unfrozenItems = items.where((item) => !item.isFrozen).toList();
    return getNearExpiryUseCase(unfrozenItems);
  }

  // ============================================
  // Action Handlers
  // ============================================

  /// Handles the consume action for an item.
  ///
  /// This method deletes the item from the fridge and shows
  /// a confirmation message. If an error occurs, it displays
  /// an error message instead.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: The widget ref
  /// - [item]: The fridge item to consume
  Future<void> _handleConsume(
      BuildContext context, WidgetRef ref, FridgeItem item) async {
    try {
      final deleteUseCase = ref.read(deleteFridgeItemUseCaseProvider);
      await deleteUseCase(item.id);
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

  /// Handles the freeze action for an item.
  ///
  /// This method updates the item to mark it as frozen, which removes
  /// it from the near-expiry list since frozen items don't expire.
  /// Shows a confirmation or error message based on the result.
  ///
  /// Parameters:
  /// - [context]: The build context
  /// - [ref]: The widget ref
  /// - [item]: The fridge item to freeze
  Future<void> _handleFreeze(
      BuildContext context, WidgetRef ref, FridgeItem item) async {
    try {
      final updatedItem = item.copyWith(
        updatedAt: DateTime.now(),
        isFrozen: true,
      );
      final updateUseCase = ref.read(updateFridgeItemUseCaseProvider);
      await updateUseCase(updatedItem);
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

  // ============================================
  // State UI Builders
  // ============================================

  /// Builds the empty state when no fridge items exist.
  ///
  /// Parameters:
  /// - [context]: The build context
  ///
  /// Returns a Card with an empty state message.
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

  /// Builds the state when all items are fresh (no near-expiry items).
  ///
  /// Parameters:
  /// - [context]: The build context
  ///
  /// Returns a Card with a success state message.
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

  /// Builds the loading state while data is being fetched.
  ///
  /// Parameters:
  /// - [context]: The build context
  ///
  /// Returns a Card with a loading indicator.
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

  /// Builds the error state when data loading fails.
  ///
  /// Parameters:
  /// - [context]: The build context
  ///
  /// Returns a Card with an error message.
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
