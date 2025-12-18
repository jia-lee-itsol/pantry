import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  static const String _keyExpiryNotifications = 'expiry_notifications_enabled';
  static const String _keyStockNotifications = 'stock_notifications_enabled';

  /// 유통기한 알림 설정 가져오기
  Future<bool> getExpiryNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyExpiryNotifications) ?? true; // 기본값: true
    } catch (e) {
      return true; // 에러 시 기본값 반환
    }
  }

  /// 재고 알림 설정 가져오기
  Future<bool> getStockNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyStockNotifications) ?? true; // 기본값: true
    } catch (e) {
      return true; // 에러 시 기본값 반환
    }
  }

  /// 유통기한 알림 설정 저장
  Future<void> setExpiryNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyExpiryNotifications, enabled);
    } catch (e) {
      throw Exception('通知設定の保存に失敗しました: $e');
    }
  }

  /// 재고 알림 설정 저장
  Future<void> setStockNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyStockNotifications, enabled);
    } catch (e) {
      throw Exception('通知設定の保存に失敗しました: $e');
    }
  }
}

