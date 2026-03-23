import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_scheduling_service.dart';
import '../../features/fridge/presentation/providers/fridge_provider.dart';
import '../../features/stock/presentation/providers/stock_provider.dart';

/// Notification Scheduling Service Provider
///
/// Provides the notification scheduling service instance for dependency injection.
final notificationSchedulingServiceProvider =
    Provider<NotificationSchedulingService>((ref) {
  return NotificationSchedulingService();
});

/// Notification Scheduling Provider
///
/// Automatically reschedules notifications whenever fridge or stock data changes.
/// This provider watches both fridge and stock item providers and triggers
/// notification rescheduling when data is updated.
///
/// The rescheduling happens asynchronously and is not awaited to avoid
/// blocking the UI thread.
final notificationSchedulingProvider = Provider<void>((ref) {
  final notificationService = ref.watch(notificationSchedulingServiceProvider);
  final fridgeItemsAsync = ref.watch(fridgeItemsProvider);
  final stockItemsAsync = ref.watch(stockItemsProvider);

  // Schedule notifications when data is loaded
  // Use 'when' to reschedule notifications whenever data changes
  fridgeItemsAsync.when(
    data: (fridgeItems) {
      stockItemsAsync.when(
        data: (stockItems) {
          // Async operation, not awaited to avoid blocking
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

