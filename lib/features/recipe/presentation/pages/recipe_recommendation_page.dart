import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../../../fridge/presentation/providers/fridge_provider.dart';
import '../../../stock/presentation/providers/stock_provider.dart';

/// 레시피 추천 페이지
class RecipeRecommendationPage extends ConsumerWidget {
  const RecipeRecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeRecommendationsProvider);
    final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
    final stockItemsAsync = ref.watch(stockItemsProvider);

    return AppScaffold(
      title: const Text('レシピ提案'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recipeRecommendationsProvider);
        },
        child: recipesAsync.when(
          data: (recipes) {
            if (recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '在庫がありません',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '冷蔵庫やストックにアイテムを追加してください',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final fridgeItems = fridgeItemsAsync.value ?? [];
            final stockItems = stockItemsAsync.value ?? [];

            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: RecipeCard(
                    recipe: recipe,
                    fridgeItems: fridgeItems,
                    stockItems: stockItems,
                  ),
                );
              },
            );
          },
          loading: () => const LoadingWidget(),
          error: (error, stackTrace) => ErrorDisplayWidget(
            message: 'レシピの取得に失敗しました',
            onRetry: () {
              ref.invalidate(recipeRecommendationsProvider);
            },
          ),
        ),
      ),
    );
  }
}
