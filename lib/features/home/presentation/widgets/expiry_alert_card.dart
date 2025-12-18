import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/spacing.dart';

class ExpiryAlertCard extends StatelessWidget {
  final int count;

  const ExpiryAlertCard({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日期限切れの食品が$count個あります',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              context.go('/fridge');
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '確認する',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.red.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

