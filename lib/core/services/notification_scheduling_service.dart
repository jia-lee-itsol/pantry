import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../../features/fridge/domain/entities/fridge_item.dart';
import '../../features/stock/domain/entities/stock_item.dart';
import 'notification_settings_service.dart';

class NotificationSchedulingService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final NotificationSettingsService _settingsService =
      NotificationSettingsService();

  bool _isInitialized = false;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // timezone 초기화
    tz.initializeTimeZones();

    // Android 초기화 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 초기화 설정
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

  /// 알림 탭 핸들러
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 처리 (필요시 네비게이션 등)
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// 유통기한 알림 스케줄링
  Future<void> scheduleExpiryNotifications(
    List<FridgeItem> items,
  ) async {
    // 알림 설정 확인
    final isEnabled = await _settingsService.getExpiryNotificationsEnabled();
    if (!isEnabled) {
      await cancelAllNotifications();
      return;
    }

    // 기존 알림 모두 취소
    await cancelAllNotifications();

    final now = DateTime.now();
    int notificationId = 1;

    for (final item in items) {
      // 냉동 아이템은 제외
      if (item.isFrozen) continue;

      final expiryDate = item.expiryDate;
      final daysUntilExpiry = expiryDate.difference(now).inDays;

      // 유통기한 3일 전 알림
      if (daysUntilExpiry == 3) {
        final scheduledDate = _getScheduledDate(expiryDate, -3);
        if (scheduledDate.isAfter(now)) {
          await _scheduleNotification(
            id: notificationId++,
            title: '賞味期限間近',
            body: '${item.name}の賞味期限まであと3日です',
            scheduledDate: scheduledDate,
          );
        }
      }

      // 유통기한 경과 알림
      if (daysUntilExpiry < 0) {
        final scheduledDate = _getScheduledDate(expiryDate, 0);
        if (scheduledDate.isAfter(now)) {
          await _scheduleNotification(
            id: notificationId++,
            title: '賞味期限切れ',
            body: '${item.name}の賞味期限が切れています',
            scheduledDate: scheduledDate,
          );
        }
      }
    }
  }

  /// 재고 부족 알림 스케줄링
  /// 목표 수량(targetQuantity)이 설정된 경우, 현재 수량이 목표 수량 아래로 떨어지면 알림 발송
  /// 목표 수량이 설정되지 않은 경우, 기본값(5) 미만일 때 알림 발송
  Future<void> scheduleStockNotifications(
    List<StockItem> items,
  ) async {
    // 알림 설정 확인
    final isEnabled = await _settingsService.getStockNotificationsEnabled();
    if (!isEnabled) {
      // 알림이 비활성화되어 있으면 기존 재고 알림 취소
      await _cancelStockNotifications();
      return;
    }

    // 기존 재고 알림 모두 취소 (중복 방지)
    await _cancelStockNotifications();

    // 재고 부족 아이템 찾기
    // 목표 수량이 설정된 경우: 현재 수량 < 목표 수량
    // 목표 수량이 없는 경우: 현재 수량 < 5 (기본값)
    final lowStockItems = items.where((item) {
      if (item.targetQuantity != null) {
        return item.quantity < item.targetQuantity!;
      } else {
        return item.quantity < 5; // 기본값
      }
    }).toList();

    if (lowStockItems.isEmpty) return;

    final now = DateTime.now();
    // 재고 부족 알림은 즉시 발송 (1초 후로 설정하여 즉시 발송)
    final scheduledDate = now.add(const Duration(seconds: 1));

    // 재고 부족 아이템이 여러 개인 경우 하나의 알림으로 통합
    if (lowStockItems.length == 1) {
      final item = lowStockItems.first;
      final targetQty = item.targetQuantity ?? 5;
      await _scheduleNotification(
        id: 1000, // 재고 알림은 1000번대 ID 사용
        title: '在庫不足',
        body: '${item.name}の在庫が目標数量($targetQty)を下回りました (現在: ${item.quantity})',
        scheduledDate: scheduledDate,
      );
    } else {
      await _scheduleNotification(
        id: 1000, // 재고 알림은 1000번대 ID 사용
        title: '在庫不足',
        body: '${lowStockItems.length}個の商品の在庫が目標数量を下回りました',
        scheduledDate: scheduledDate,
      );
    }
  }

  /// 재고 알림 취소 (1000번대 ID)
  Future<void> _cancelStockNotifications() async {
    // 재고 알림은 1000번대 ID를 사용하므로 1000번 알림 취소
    await cancelNotification(1000);
  }

  /// 알림 스케줄링 (지정된 날짜/시간에)
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
          channelDescription: '賞味期限や在庫に関する通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// 알림 스케줄링 날짜 계산 (오늘 오전 9시)
  DateTime _getScheduledDate(DateTime baseDate, int daysOffset) {
    final targetDate = baseDate.add(Duration(days: daysOffset));
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      9, // 오전 9시
    );
  }

  /// 냉장고 부족 알림 스케줄링
  /// 목표 수량(targetQuantity)이 설정된 경우, 현재 수량이 목표 수량 아래로 떨어지면 알림 발송
  /// 목표 수량이 설정되지 않은 경우, 기본값(5) 미만일 때 알림 발송
  Future<void> scheduleFridgeStockNotifications(
    List<FridgeItem> items,
  ) async {
    // 알림 설정 확인
    final isEnabled = await _settingsService.getStockNotificationsEnabled();
    if (!isEnabled) {
      // 알림이 비활성화되어 있으면 기존 냉장고 재고 알림 취소
      await _cancelFridgeStockNotifications();
      return;
    }

    // 기존 냉장고 재고 알림 모두 취소 (중복 방지)
    await _cancelFridgeStockNotifications();

    // 재고 부족 아이템 찾기
    // 목표 수량이 설정된 경우: 현재 수량 < 목표 수량
    // 목표 수량이 없는 경우: 현재 수량 < 5 (기본값)
    final lowStockItems = items.where((item) {
      if (item.targetQuantity != null) {
        return item.quantity < item.targetQuantity!;
      } else {
        return item.quantity < 5; // 기본값
      }
    }).toList();

    if (lowStockItems.isEmpty) return;

    final now = DateTime.now();
    // 냉장고 부족 알림은 즉시 발송 (1초 후로 설정하여 즉시 발송)
    final scheduledDate = now.add(const Duration(seconds: 1));

    // 재고 부족 아이템이 여러 개인 경우 하나의 알림으로 통합
    if (lowStockItems.length == 1) {
      final item = lowStockItems.first;
      final targetQty = item.targetQuantity ?? 5;
      await _scheduleNotification(
        id: 2000, // 냉장고 재고 알림은 2000번대 ID 사용
        title: '在庫不足',
        body: '${item.name}の在庫が目標数量($targetQty)を下回りました (現在: ${item.quantity})',
        scheduledDate: scheduledDate,
      );
    } else {
      await _scheduleNotification(
        id: 2000, // 냉장고 재고 알림은 2000번대 ID 사용
        title: '在庫不足',
        body: '${lowStockItems.length}個の商品の在庫が目標数量を下回りました',
        scheduledDate: scheduledDate,
      );
    }
  }

  /// 냉장고 재고 알림 취소 (2000번대 ID)
  Future<void> _cancelFridgeStockNotifications() async {
    // 냉장고 재고 알림은 2000번대 ID를 사용하므로 2000번 알림 취소
    await cancelNotification(2000);
  }

  /// 모든 알림 재스케줄링 (데이터 변경 시 호출)
  Future<void> rescheduleAllNotifications({
    required List<FridgeItem> fridgeItems,
    required List<StockItem> stockItems,
  }) async {
    await scheduleExpiryNotifications(fridgeItems);
    await scheduleStockNotifications(stockItems);
    await scheduleFridgeStockNotifications(fridgeItems);
  }
}

