import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/spacing.dart';
import '../../../../core/design/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/spending_summary.dart';
import '../providers/analytics_provider.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';

class SpendingStatsPage extends ConsumerWidget {
  const SpendingStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(filteredSpendingSummaryProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return AppScaffold(
      title: const Text('支出統計'),
      body: Column(
        children: [
          _buildPeriodSelector(context, ref, selectedPeriod),
          Expanded(
            child: summaryAsync.when(
              data: (summary) => _buildContent(context, summary),
              loading: () => const LoadingWidget(),
              error: (error, _) => _buildErrorState(context, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    AnalyticsPeriod selected,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SegmentedButton<AnalyticsPeriod>(
        segments: const [
          ButtonSegment(
            value: AnalyticsPeriod.week,
            label: Text('1週間'),
          ),
          ButtonSegment(
            value: AnalyticsPeriod.month,
            label: Text('1ヶ月'),
          ),
          ButtonSegment(
            value: AnalyticsPeriod.threeMonths,
            label: Text('3ヶ月'),
          ),
          ButtonSegment(
            value: AnalyticsPeriod.year,
            label: Text('1年'),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (Set<AnalyticsPeriod> newSelection) {
          ref.read(selectedPeriodProvider.notifier).setPeriod(newSelection.first);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SpendingSummary summary) {
    if (summary.totalSpending == 0) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh will be handled by invalidating providers
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpendingSummaryCard(summary: summary),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle(context, 'カテゴリ別支出'),
            const SizedBox(height: AppSpacing.md),
            CategoryPieChart(spendingByCategory: summary.spendingByCategory),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle(context, '月別支出'),
            const SizedBox(height: AppSpacing.md),
            MonthlyBarChart(monthlySpending: summary.monthlySpending),
            const SizedBox(height: AppSpacing.lg),
            _buildTopCategories(context, summary),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildTopCategories(BuildContext context, SpendingSummary summary) {
    final topCategories = summary.topCategories;
    if (topCategories.isEmpty) return const SizedBox.shrink();

    final formatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'トップカテゴリ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...topCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = (category.value / summary.totalSpending * 100);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _getCategoryColor(index),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(category.key),
                    ),
                    Text(
                      formatter.format(category.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'データがありません',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'レシートをスキャンして\n購入履歴を記録してください',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: AppSpacing.md),
          Text('エラーが発生しました'),
          Text(
            error.toString(),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
