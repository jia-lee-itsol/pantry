import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_scheduling_service.dart';
import '../../features/fridge/presentation/providers/fridge_provider.dart';
import '../../features/stock/presentation/providers/stock_provider.dart';

final notificationSchedulingServiceProvider =
    Provider<NotificationSchedulingService>((ref) {
  return NotificationSchedulingService();
});

/// 알림 스케줄링을 자동으로 수행하는 Provider
final notificationSchedulingProvider = Provider<void>((ref) {
  final notificationService = ref.watch(notificationSchedulingServiceProvider);
  final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
  final stockItemsAsync = ref.watch(stockItemsProvider);

  // 데이터가 로드되면 알림 스케줄링
  // when을 사용하여 데이터 변경 시마다 알림 재스케줄링
  fridgeItemsAsync.when(
    data: (fridgeItems) {
      stockItemsAsync.when(
        data: (stockItems) {
          // 비동기 작업이므로 unawaited로 처리
          notificationService.rescheduleAllNotifications(
            fridgeItems: fridgeItems,
            stockItems: stockItems,
          );
        },
        loading: () {},
        error: (_, __) {},
      );
    },
    loading: () {},
    error: (_, __) {},
  );

  return;
});

