import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/design/widgets/section_card.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/notification_scheduling_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/expiry_alert_card.dart';
import '../widgets/near_expiry_item_tile.dart';
import '../widgets/low_stock_alert_card.dart';
// import '../widgets/sale_item_card.dart';
import 'near_expiry_list_page.dart';
// import 'sale_items_page.dart';
import '../../../fridge/domain/entities/fridge_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
    final stockItemsAsync = ref.watch(stockItemsProvider);
    
    // 알림 스케줄링 (데이터 변경 시 자동으로 알림 업데이트)
    ref.watch(notificationSchedulingProvider);

    return AppScaffold(
      title: Text(AppStrings.appName),
      actions: [
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
              // 알림 섹션
              fridgeItemsAsync.when(
                data: (items) {
                  final todayExpiryCount = items.where((item) {
                    final expiry = DateTime(
                      item.expiryDate.year,
                      item.expiryDate.month,
                      item.expiryDate.day,
                    );
                    final today = DateTime.now();
                    final todayOnly = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    );
                    return expiry == todayOnly;
                  }).length;

                  return ExpiryAlertCard(count: todayExpiryCount);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 재고 부족 알림 섹션
              stockItemsAsync.when(
                data: (items) {
                  final lowStockItems = items.where((item) {
                    if (item.targetQuantity != null) {
                      return item.quantity < item.targetQuantity!;
                    } else {
                      return item.quantity < 5; // 기본값
                    }
                  }).toList();

                  return LowStockAlertCard(count: lowStockItems.length);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 냉장고 부족 알림 섹션
              fridgeItemsAsync.when(
                data: (items) {
                  final lowFridgeItems = items.where((item) {
                    if (item.targetQuantity != null) {
                      return item.quantity < item.targetQuantity!;
                    } else {
                      return item.quantity < 5; // 기본값
                    }
                  }).toList();

                  if (lowFridgeItems.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return InkWell(
                    onTap: () {
                      context.go('/low-fridge-stock');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.kitchen_outlined,
                            color: Colors.orange.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '冷蔵庫在庫不足の商品が${lowFridgeItems.length}個あります',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 요약 카드
              Row(
                children: [
                  fridgeItemsAsync.when(
                    data: (items) {
                      final nearExpiryCount = items.where((item) {
                        // 냉동 아이템은 제외
                        if (item.isFrozen) {
                          return false;
                        }
                        final daysUntilExpiry = item.expiryDate
                            .difference(DateTime.now())
                            .inDays;
                        return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
                      }).length;

                      return SummaryCard(
                        title: '期限間近',
                        count: nearExpiryCount,
                        subtitle: '7日以内',
                        icon: Icons.calendar_today,
                        iconColor: Colors.orange,
                      );
                    },
                    loading: () => SummaryCard(
                      title: '期限間近',
                      count: 0,
                      subtitle: '7日以内',
                      icon: Icons.calendar_today,
                      iconColor: Colors.orange,
                    ),
                    error: (_, __) => SummaryCard(
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
                    loading: () => SummaryCard(
                      title: '備蓄品',
                      count: 0,
                      subtitle: 'アイテム',
                      icon: Icons.inventory_2,
                      iconColor: Colors.blue,
                    ),
                    error: (_, __) => SummaryCard(
                      title: '備蓄品',
                      count: 0,
                      subtitle: 'アイテム',
                      icon: Icons.inventory_2,
                      iconColor: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // 만료 임박 상품 섹션
              Row(
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
                      final nearExpiryItems = items.where((item) {
                        // 냉동 아이템은 제외
                        if (item.isFrozen) {
                          return false;
                        }
                        final daysUntilExpiry = item.expiryDate
                            .difference(DateTime.now())
                            .inDays;
                        return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
                      }).length;

                      if (nearExpiryItems == 0) {
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
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              fridgeItemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
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
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '冷蔵庫に商品を追加してみてください。',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final nearExpiryItems =
                      items.where((item) {
                          // 냉동 아이템은 제외
                          if (item.isFrozen) {
                            return false;
                          }
                          final daysUntilExpiry = item.expiryDate
                              .difference(DateTime.now())
                              .inDays;
                          return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
                        }).toList()
                        ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

                  if (nearExpiryItems.isEmpty) {
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
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'すべての商品が安全です。',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: nearExpiryItems
                        .take(5)
                        .map(
                          (item) => NearExpiryItemTile(
                            item: item,
                            onConsume: () async {
                              try {
                                await ref
                                    .read(fridgeRepositoryProvider)
                                    .deleteFridgeItem(item.id);
                                ref.invalidate(fridgeItemsProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item.name}を消費完了しました。',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('処理失敗: $e')),
                                  );
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
                                    SnackBar(
                                      content: Text('${item.name}を冷凍処理しました。'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('処理失敗: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                error: (error, stack) => Card(
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // レシートOCRセクション
              SectionCard(
                title: 'レシートスキャン',
                subtitle: 'レシートから商品を自動登録',
                icon: Icons.receipt_long,
                route: '/receipt-scan',
              ),

              const SizedBox(height: AppSpacing.md),

              // 레시피 추천 섹션
              SectionCard(
                title: 'レシピ提案',
                subtitle: '在庫に合わせたレシピを提案',
                icon: Icons.restaurant_menu,
                route: '/recipe',
              ),

              // const SizedBox(height: AppSpacing.lg),

              // // 할인 상품 정보 섹션
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       '近くのセール情報',
              //       style: Theme.of(context).textTheme.titleLarge?.copyWith(
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     TextButton(
              //       onPressed: () {
              //         // TODO: 할인 상품 상세 페이지 구현
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(
              //             content: Text('セール情報機能は準備中です。'),
              //           ),
              //         );
              //       },
              //       child: const Text('もっと見る'),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: AppSpacing.md),
              // Card(
              //   elevation: 2,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Container(
              //     height: 120,
              //     padding: const EdgeInsets.all(AppSpacing.md),
              //     child: Center(
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Icon(
              //             Icons.local_offer_outlined,
              //             size: 48,
              //             color: Colors.grey.shade400,
              //           ),
              //           const SizedBox(height: AppSpacing.sm),
              //           Text(
              //             'セール情報は準備中です',
              //             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //               color: Colors.grey.shade600,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              //   child: ListView(
              //     scrollDirection: Axis.horizontal,
              //     children: const [
              //       SaleItemCard(
              //         storeName: 'スーパーマーケット',
              //         productName: '新鮮野菜セット',
              //         discount: '30% OFF',
              //       ),
              //       SaleItemCard(
              //         storeName: 'フレッシュマート',
              //         productName: '国産牛肉',
              //         discount: '20% OFF',
              //       ),
              //       SaleItemCard(
              //         storeName: 'デイリーマート',
              //         productName: 'フルーツ特価',
              //         discount: '15% OFF',
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
