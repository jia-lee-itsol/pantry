import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/design/spacing.dart';
import '../../../fridge/domain/entities/fridge_item.dart';

class NearExpiryItemTile extends StatelessWidget {
  final FridgeItem item;
  final Future<void> Function()? onConsume;
  final Future<void> Function()? onFreeze;

  const NearExpiryItemTile({
    super.key,
    required this.item,
    this.onConsume,
    this.onFreeze,
  });

  String _getExpiryText(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final difference = expiry.difference(today).inDays;

    if (difference < 0) {
      return '期限切れ';
    } else if (difference == 0) {
      return '今日まで';
    } else if (difference == 1) {
      return '残り1日';
    } else {
      return '残り$difference日';
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = item.expiryDate.difference(DateTime.now()).inDays;
    final isToday = daysUntilExpiry == 0;
    final isExpired = daysUntilExpiry < 0;

    final tile = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text(item.name),
            if (item.isFrozen) ...[
              const SizedBox(width: 8),
              Icon(Icons.ac_unit, color: Colors.blue.shade400, size: 18),
            ],
          ],
        ),
        subtitle: Text(item.isFrozen ? '冷凍庫' : '冷蔵庫'),
        trailing: item.isFrozen
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.ac_unit, color: Colors.blue.shade400, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '冷凍',
                    style: TextStyle(
                      color: Colors.blue.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getExpiryText(item.expiryDate),
                    style: TextStyle(
                      color: isToday || isExpired ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    app_date_utils.DateUtils.formatDate(item.expiryDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
      ),
    );

    // 슬라이드 제스처가 필요한 경우에만 Dismissible로 감싸기
    if (onConsume == null && onFreeze == null) {
      return tile;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.ac_unit, color: Colors.white, size: 32),
            SizedBox(width: AppSpacing.sm),
            Text(
              '冷凍処理',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 32),
            SizedBox(width: AppSpacing.sm),
            Text(
              '消費完了',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        try {
          if (direction == DismissDirection.startToEnd && onFreeze != null) {
            // 왼쪽으로 슬라이드: 냉동 처리
            await onFreeze!();
            return true;
          } else if (direction == DismissDirection.endToStart &&
              onConsume != null) {
            // 오른쪽으로 슬라이드: 소비 완료
            await onConsume!();
            return true;
          }
        } catch (e) {
          // 에러 발생 시 dismiss 취소
          return false;
        }
        return false;
      },
      child: tile,
    );
  }
}
