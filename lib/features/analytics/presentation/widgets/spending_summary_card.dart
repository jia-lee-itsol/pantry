import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/spacing.dart';
import '../../domain/entities/spending_summary.dart';

class SpendingSummaryCard extends StatelessWidget {
  final SpendingSummary summary;

  const SpendingSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支出サマリー',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatRow(
              context,
              icon: Icons.monetization_on,
              label: '総支出',
              value: formatter.format(summary.totalSpending),
              valueColor: theme.colorScheme.primary,
              isLarge: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildStatRow(
              context,
              icon: Icons.shopping_cart,
              label: '購入アイテム数',
              value: '${summary.totalItems}点',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildStatRow(
              context,
              icon: Icons.category,
              label: 'カテゴリ数',
              value: '${summary.spendingByCategory.length}種類',
            ),
            if (summary.totalItems > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildStatRow(
                context,
                icon: Icons.calculate,
                label: '平均単価',
                value: formatter.format(summary.totalSpending / summary.totalItems),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isLarge = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: isLarge ? 28 : 20,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: isLarge
              ? theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                )
              : theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }
}
