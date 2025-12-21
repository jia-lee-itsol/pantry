import 'package:flutter/material.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/recipe.dart';
import '../../../fridge/domain/entities/fridge_item.dart';
import '../../../stock/domain/entities/stock_item.dart';

/// 레시피 카드 위젯
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final List<FridgeItem> fridgeItems;
  final List<StockItem> stockItems;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.fridgeItems,
    required this.stockItems,
  });

  /// 기본 조미료인지 확인
  bool _isBasicSeasoning(String ingredient) {
    // 재료명에서 수량 정보 제거 (예: "玉ねぎ (1/4個)" -> "玉ねぎ")
    final ingredientName = ingredient
        .split('(')
        .first
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[0-9/個mlg]'), '')
        .trim();

    // 기본 조미료 목록
    const basicSeasonings = [
      '塩',
      '砂糖',
      'こしょう',
      '醤油',
      'みりん',
      '酒',
      '酢',
      '油',
      'バター',
      'オリーブオイル',
      'ハチミツ',
      '味噌',
      'だし',
      'だしの素',
      '白だし',
      'めんつゆ',
      'ごま油',
      'コンソメ',
      'ケチャップ',
      'マヨネーズ',
      '中華だし',
      '鶏ガラ',
      '顆粒だし',
      'ポン酢',
      '焼肉のたれ',
      'オイスターソース',
    ];

    // 기본 조미료 확인
    for (final seasoning in basicSeasonings) {
      if (ingredientName.contains(seasoning.toLowerCase()) ||
          seasoning.toLowerCase().contains(ingredientName)) {
        return true;
      }
    }

    return false;
  }

  /// 재료가 재고에 있는지 확인
  bool _hasIngredient(String ingredient) {
    // 기본 조미료는 항상 있다고 간주하지만 마크는 표시하지 않음
    if (_isBasicSeasoning(ingredient)) {
      return true;
    }

    // 재료명에서 수량 정보 제거 (예: "玉ねぎ (1/4個)" -> "玉ねぎ")
    final ingredientName = ingredient
        .split('(')
        .first
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[0-9/個mlg]'), '')
        .trim();

    // 냉장고 재고 확인
    for (final item in fridgeItems) {
      final itemName = item.name.toLowerCase();
      if (ingredientName.contains(itemName) ||
          itemName.contains(ingredientName)) {
        return true;
      }
    }

    // 재고 확인
    for (final item in stockItems) {
      final itemName = item.name.toLowerCase();
      if (ingredientName.contains(itemName) ||
          itemName.contains(ingredientName)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant_menu,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          recipe.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (recipe.cookingTime != null) ...[
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${recipe.cookingTime}分',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (recipe.servings != null) ...[
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${recipe.servings}人分',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 재료 섹션
                if (recipe.ingredients.isNotEmpty) ...[
                  Text(
                    '材料',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...recipe.ingredients.map((ingredient) {
                    final isBasicSeasoning = _isBasicSeasoning(ingredient);
                    final hasIngredient = _hasIngredient(ingredient);
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        bottom: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: hasIngredient
                                        ? null
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withAlpha(127),
                                  ),
                            ),
                          ),
                          // 기본 조미료는 마크 표시하지 않음
                          if (!isBasicSeasoning) ...[
                            const SizedBox(width: AppSpacing.xs),
                            if (hasIngredient)
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green,
                              )
                            else
                              Icon(
                                Icons.cancel,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),
                ],
                // 조리법 섹션
                if (recipe.instructions.isNotEmpty) ...[
                  Text(
                    '作り方',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final instruction = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        bottom: AppSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              instruction,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
