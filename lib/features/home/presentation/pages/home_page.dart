import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/widgets/section_card.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/notification_scheduling_provider.dart';
import '../../../../core/providers/usecase_providers.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';
import '../../../household/presentation/providers/household_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/expiry_alert_card.dart';
import '../widgets/low_stock_alert_card.dart';
import '../widgets/household_request_alert.dart';
import '../widgets/low_fridge_stock_alert.dart';
import '../widgets/near_expiry_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
    final stockItemsAsync = ref.watch(stockItemsProvider);

    ref.watch(autoMigrationProvider);
    ref.watch(notificationSchedulingProvider);

    return AppScaffold(
      title: Text(AppStrings.appName),
      actions: [
        Semantics(
          label: '검색',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
            tooltip: '検索',
          ),
        ),
        Semantics(
          label: '피난소 지도',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.warning),
            onPressed: () {
              context.push('/map');
            },
            tooltip: '避難所',
          ),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fridgeItemsProvider);
          ref.invalidate(stockItemsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HouseholdRequestAlert(),
              _buildExpiryAlert(fridgeItemsAsync, ref),
              _buildLowStockAlert(stockItemsAsync, ref),
              _buildLowFridgeStockAlert(fridgeItemsAsync, ref),
              _buildSummaryCards(fridgeItemsAsync, stockItemsAsync, ref),
              const SizedBox(height: AppSpacing.lg),
              NearExpirySection(fridgeItemsAsync: fridgeItemsAsync),
              const SizedBox(height: AppSpacing.lg),
              const SectionCard(
                title: 'レシートスキャン',
                subtitle: 'レシートから商品を自動登録',
                icon: Icons.receipt_long,
                route: '/receipt-scan',
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionCard(
                title: 'レシピ提案',
                subtitle: '在庫に合わせたレシピを提案',
                icon: Icons.restaurant_menu,
                route: '/recipe',
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionCard(
                title: '支出統計',
                subtitle: '購入履歴と支出を分析',
                icon: Icons.analytics,
                route: '/analytics',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryAlert(AsyncValue<List<FridgeItem>> fridgeItemsAsync, WidgetRef ref) {
    return fridgeItemsAsync.when(
      data: (items) {
        final checkExpiryUseCase = ref.read(checkExpiryUseCaseProvider);
        final todayExpiryCount = items.where((item) {
          return checkExpiryUseCase.isExpiredToday(item.expiryDate);
        }).length;
        return ExpiryAlertCard(count: todayExpiryCount);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildLowStockAlert(AsyncValue<List<StockItem>> stockItemsAsync, WidgetRef ref) {
    return stockItemsAsync.when(
      data: (items) {
        final checkLowStockUseCase = ref.read(checkLowStockUseCaseProvider);
        final lowStockItems = checkLowStockUseCase.filterLowStock<StockItem>(
          items: items,
          getQuantity: (item) => item.quantity,
          getTargetQuantity: (item) => item.targetQuantity,
        );
        return LowStockAlertCard(count: lowStockItems.length);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildLowFridgeStockAlert(AsyncValue<List<FridgeItem>> fridgeItemsAsync, WidgetRef ref) {
    return fridgeItemsAsync.when(
      data: (items) {
        final checkLowStockUseCase = ref.read(checkLowStockUseCaseProvider);
        final lowFridgeItems = checkLowStockUseCase.filterLowStock<FridgeItem>(
          items: items,
          getQuantity: (item) => item.quantity,
          getTargetQuantity: (item) => item.targetQuantity,
        );
        return LowFridgeStockAlert(lowStockItems: lowFridgeItems);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryCards(
    AsyncValue<List<FridgeItem>> fridgeItemsAsync,
    AsyncValue<List<StockItem>> stockItemsAsync,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        fridgeItemsAsync.when(
          data: (items) {
            final getNearExpiryUseCase = ref.read(getNearExpiryItemsUseCaseProvider);
            final unfrozenItems = items.where((item) => !item.isFrozen).toList();
            final nearExpiryCount = getNearExpiryUseCase(unfrozenItems).length;
            return SummaryCard(
              title: '期限間近',
              count: nearExpiryCount,
              subtitle: '7日以内',
              icon: Icons.calendar_today,
              iconColor: Colors.orange,
            );
          },
          loading: () => const SummaryCard(
            title: '期限間近',
            count: 0,
            subtitle: '7日以内',
            icon: Icons.calendar_today,
            iconColor: Colors.orange,
          ),
          error: (_, _) => const SummaryCard(
            title: '期限間近',
            count: 0,
            subtitle: '7日以内',
            icon: Icons.calendar_today,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        stockItemsAsync.when(
          data: (items) => SummaryCard(
            title: '備蓄品',
            count: items.length,
            subtitle: 'アイテム',
            icon: Icons.inventory_2,
            iconColor: Colors.blue,
          ),
          loading: () => const SummaryCard(
            title: '備蓄品',
            count: 0,
            subtitle: 'アイテム',
            icon: Icons.inventory_2,
            iconColor: Colors.blue,
          ),
          error: (_, _) => const SummaryCard(
            title: '備蓄品',
            count: 0,
            subtitle: 'アイテム',
            icon: Icons.inventory_2,
            iconColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}
