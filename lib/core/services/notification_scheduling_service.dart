import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../../features/fridge/domain/entities/fridge_item.dart';
import '../../features/stock/domain/entities/stock_item.dart';
import '../domain/usecases/check_low_stock_usecase.dart';
import '../domain/usecases/check_expiry_usecase.dart';
import 'notification_settings_service.dart';

/// Notification Scheduling Service
///
/// Manages local push notifications for expiry dates and low stock alerts.
/// This service integrates with flutter_local_notifications to schedule
/// notifications based on item expiry dates and stock levels.
///
/// Features:
/// - Expiry date notifications (3 days before and on expiry)
/// - Low stock notifications for fridge and pantry items
/// - User-configurable notification settings
/// - Automatic notification rescheduling on data changes
/// - Support for both Android and iOS platforms
///
/// Notification ID Ranges:
/// - 1-999: Expiry notifications
/// - 1000: Stock notifications (pantry)
/// - 2000: Stock notifications (fridge)
class NotificationSchedulingService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final NotificationSettingsService _settingsService;
  final CheckLowStockUseCase _checkLowStockUseCase;
  final CheckExpiryUseCase _checkExpiryUseCase;

  bool _isInitialized = false;

  NotificationSchedulingService({
    NotificationSettingsService? settingsService,
    CheckLowStockUseCase? checkLowStockUseCase,
    CheckExpiryUseCase? checkExpiryUseCase,
  })  : _settingsService = settingsService ?? NotificationSettingsService(),
        _checkLowStockUseCase = checkLowStockUseCase ?? CheckLowStockUseCase(),
        _checkExpiryUseCase = checkExpiryUseCase ?? CheckExpiryUseCase();

  /// Initializes the notification service
  ///
  /// Sets up the notification plugin with platform-specific settings
  /// and initializes timezone data. This must be called before scheduling
  /// any notifications.
  ///
  /// Only initializes once even if called multiple times.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Notification tap handler
  ///
  /// Called when a user taps on a notification.
  /// Can be used for navigation or other actions.
  ///
  /// Parameters:
  ///   - response: The notification response containing payload data
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap (e.g., navigation)
  }

  /// Cancels all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancels a specific notification
  ///
  /// Parameters:
  ///   - id: The notification ID to cancel
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Schedules expiry date notifications
  ///
  /// Creates notifications for items that are:
  /// - Approaching expiry (3 days before)
  /// - Expired (on expiry date)
  ///
  /// Frozen items are excluded from notifications.
  /// Cancels all existing expiry notifications before scheduling new ones.
  ///
  /// Parameters:
  ///   - items: List of fridge items to check for expiry
  Future<void> scheduleExpiryNotifications(
    List<FridgeItem> items,
  ) async {
    // Check notification settings
    final isEnabled = await _settingsService.getExpiryNotificationsEnabled();
    if (!isEnabled) {
      await cancelAllNotifications();
      return;
    }

    // Cancel all existing notifications
    await cancelAllNotifications();

    final now = DateTime.now();
    int notificationId = 1;

    for (final item in items) {
      // Skip frozen items
      if (item.isFrozen) continue;

      final expiryDate = item.expiryDate;
      final daysUntilExpiry = _checkExpiryUseCase.daysUntilExpiry(expiryDate);

      // Schedule notification 3 days before expiry
      if (_checkExpiryUseCase.shouldNotifyExpiry(expiryDate)) {
        final scheduledDate = _getScheduledDate(expiryDate, -CheckExpiryUseCase.notificationThresholdDays);
        if (scheduledDate.isAfter(now)) {
          await _scheduleNotification(
            id: notificationId++,
            title: 'Expiry Date Approaching',
            body: '${item.name} expires in $daysUntilExpiry days',
            scheduledDate: scheduledDate,
          );
        }
      }

      // Schedule notification for expired items
      if (_checkExpiryUseCase.isExpired(expiryDate)) {
        final scheduledDate = _getScheduledDate(expiryDate, 0);
        if (scheduledDate.isAfter(now)) {
          await _scheduleNotification(
            id: notificationId++,
            title: 'Expired',
            body: '${item.name} has expired',
            scheduledDate: scheduledDate,
          );
        }
      }
    }
  }

  /// Schedules low stock notifications for pantry items
  ///
  /// Sends notifications when stock quantity falls below the target quantity.
  /// - If targetQuantity is set: Alerts when current < target
  /// - If targetQuantity is null: Alerts when current < default threshold (5)
  ///
  /// Notifications are sent immediately (with 1 second delay).
  ///
  /// Parameters:
  ///   - items: List of stock items to check
  Future<void> scheduleStockNotifications(
    List<StockItem> items,
  ) async {
    // Check notification settings
    final isEnabled = await _settingsService.getStockNotificationsEnabled();
    if (!isEnabled) {
      // Cancel existing stock notifications if disabled
      await _cancelStockNotifications();
      return;
    }

    // Cancel existing stock notifications (prevent duplicates)
    await _cancelStockNotifications();

    // Find low stock items using use case
    final lowStockItems = _checkLowStockUseCase.filterLowStock(
      items: items,
      getQuantity: (item) => item.quantity,
      getTargetQuantity: (item) => item.targetQuantity,
    );

    if (lowStockItems.isEmpty) return;

    final now = DateTime.now();
    // Send stock notification immediately (1 second delay)
    final scheduledDate = now.add(const Duration(seconds: 1));

    // Combine multiple items into one notification
    if (lowStockItems.length == 1) {
      final item = lowStockItems.first;
      final targetQty = item.targetQuantity ?? CheckLowStockUseCase.defaultThreshold;
      await _scheduleNotification(
        id: 1000, // Stock notifications use ID 1000
        title: 'Low Stock',
        body: '${item.name} stock is below target ($targetQty) - Current: ${item.quantity}',
        scheduledDate: scheduledDate,
      );
    } else {
      await _scheduleNotification(
        id: 1000, // Stock notifications use ID 1000
        title: 'Low Stock',
        body: '${lowStockItems.length} items are below target stock levels',
        scheduledDate: scheduledDate,
      );
    }
  }

  /// Cancels stock notifications (ID 1000)
  Future<void> _cancelStockNotifications() async {
    await cancelNotification(1000);
  }

  /// Schedules a notification at a specific date and time
  ///
  /// Parameters:
  ///   - id: Unique notification ID
  ///   - title: Notification title
  ///   - body: Notification body text
  ///   - scheduledDate: When to show the notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pantry_notifications',
          'Pantry Notifications',
          channelDescription: 'Notifications about expiry dates and stock levels',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Calculates scheduled notification date (9 AM)
  ///
  /// Adds the specified day offset to the base date and sets the time to 9 AM.
  ///
  /// Parameters:
  ///   - baseDate: The base date to calculate from
  ///   - daysOffset: Number of days to add (can be negative)
  ///
  /// Returns: DateTime set to 9 AM on the calculated date
  DateTime _getScheduledDate(DateTime baseDate, int daysOffset) {
    final targetDate = baseDate.add(Duration(days: daysOffset));
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      9, // 9 AM
    );
  }

  /// Schedules low stock notifications for fridge items
  ///
  /// Sends notifications when fridge item quantity falls below the target quantity.
  /// - If targetQuantity is set: Alerts when current < target
  /// - If targetQuantity is null: Alerts when current < default threshold
  ///
  /// Notifications are sent immediately (with 1 second delay).
  ///
  /// Parameters:
  ///   - items: List of fridge items to check
  Future<void> scheduleFridgeStockNotifications(
    List<FridgeItem> items,
  ) async {
    // Check notification settings
    final isEnabled = await _settingsService.getStockNotificationsEnabled();
    if (!isEnabled) {
      // Cancel existing fridge stock notifications if disabled
      await _cancelFridgeStockNotifications();
      return;
    }

    // Cancel existing fridge stock notifications (prevent duplicates)
    await _cancelFridgeStockNotifications();

    // Find low stock items using use case
    final lowStockItems = _checkLowStockUseCase.filterLowStock(
      items: items,
      getQuantity: (item) => item.quantity,
      getTargetQuantity: (item) => item.targetQuantity,
    );

    if (lowStockItems.isEmpty) return;

    final now = DateTime.now();
    // Send fridge stock notification immediately (1 second delay)
    final scheduledDate = now.add(const Duration(seconds: 1));

    // Combine multiple items into one notification
    if (lowStockItems.length == 1) {
      final item = lowStockItems.first;
      final targetQty = item.targetQuantity ?? CheckLowStockUseCase.defaultThreshold;
      await _scheduleNotification(
        id: 2000, // Fridge stock notifications use ID 2000
        title: 'Low Stock',
        body: '${item.name} stock is below target ($targetQty) - Current: ${item.quantity}',
        scheduledDate: scheduledDate,
      );
    } else {
      await _scheduleNotification(
        id: 2000, // Fridge stock notifications use ID 2000
        title: 'Low Stock',
        body: '${lowStockItems.length} fridge items are below target stock levels',
        scheduledDate: scheduledDate,
      );
    }
  }

  /// Cancels fridge stock notifications (ID 2000)
  Future<void> _cancelFridgeStockNotifications() async {
    await cancelNotification(2000);
  }

  /// Reschedules all notifications
  ///
  /// Called when data changes to update all notification schedules.
  /// Reschedules expiry notifications and both stock notification types.
  ///
  /// Parameters:
  ///   - fridgeItems: List of fridge items
  ///   - stockItems: List of pantry/stock items
  Future<void> rescheduleAllNotifications({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
  }) async {
    await scheduleExpiryNotifications(fridgeItems);
    await scheduleStockNotifications(stockItems);
    await scheduleFridgeStockNotifications(fridgeItems);
  }
}

