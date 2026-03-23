import 'package:shared_preferences/shared_preferences.dart';

/// Notification Settings Service
///
/// Manages user preferences for notification settings using SharedPreferences.
/// This service provides methods to enable/disable different types of notifications
/// such as expiry date notifications and stock level notifications.
///
/// Settings are persisted locally and synchronized across app sessions.
class NotificationSettingsService {
  static const String _keyExpiryNotifications = 'expiry_notifications_enabled';
  static const String _keyStockNotifications = 'stock_notifications_enabled';

  /// Gets the expiry notification setting
  ///
  /// Returns `true` if expiry notifications are enabled, `false` otherwise.
  /// Defaults to `true` if no setting has been saved yet.
  ///
  /// Returns a `Future` with a `bool` indicating whether expiry notifications are enabled
  Future<bool> getExpiryNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyExpiryNotifications) ?? true; // 기본값: true
    } catch (e) {
      return true; // 에러 시 기본값 반환
    }
  }

  /// Gets the stock notification setting
  ///
  /// Returns `true` if stock notifications are enabled, `false` otherwise.
  /// Defaults to `true` if no setting has been saved yet.
  ///
  /// Returns a `Future` with a `bool` indicating whether stock notifications are enabled
  Future<bool> getStockNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyStockNotifications) ?? true; // 기본값: true
    } catch (e) {
      return true; // 에러 시 기본값 반환
    }
  }

  /// Sets the expiry notification setting
  ///
  /// Saves the user's preference for expiry notifications.
  ///
  /// Parameters:
  ///   - enabled: `true` to enable expiry notifications, `false` to disable
  ///
  /// Throws: Exception if saving fails
  Future<void> setExpiryNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyExpiryNotifications, enabled);
    } catch (e) {
      throw Exception('Failed to save notification settings: $e');
    }
  }

  /// Sets the stock notification setting
  ///
  /// Saves the user's preference for stock level notifications.
  ///
  /// Parameters:
  ///   - enabled: `true` to enable stock notifications, `false` to disable
  ///
  /// Throws: Exception if saving fails
  Future<void> setStockNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyStockNotifications, enabled);
    } catch (e) {
      throw Exception('Failed to save notification settings: $e');
    }
  }
}

