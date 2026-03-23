/// Check Expiry Use Case
///
/// Business logic for checking expiry-related rules and conditions.
/// This use case encapsulates core business rules for expiry date handling,
/// including notifications, warnings, and status checks.
///
/// Business Rules:
/// - Notification threshold: 3 days before expiry
/// - Near expiry threshold: 7 days before expiry
/// - Expiry checks are based on calendar dates (time is ignored)
///
/// This use case is stateless and can be reused across the application.
class CheckExpiryUseCase {
  /// Threshold for sending expiry notifications (3 days before)
  static const int notificationThresholdDays = 3;

  /// Threshold for marking items as near expiry (7 days before)
  static const int nearExpiryThresholdDays = 7;

  /// Checks if item expires today
  ///
  /// Compares only the date portion, ignoring time.
  ///
  /// Parameters:
  ///   - expiryDate: The expiry date to check
  ///
  /// Returns: `true` if the item expires today, `false` otherwise
  bool isExpiredToday(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry == today;
  }

  /// Checks if item is expired (past the expiry date)
  ///
  /// Compares only the date portion, ignoring time.
  ///
  /// Parameters:
  ///   - expiryDate: The expiry date to check
  ///
  /// Returns: `true` if the item has expired, `false` otherwise
  bool isExpired(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.isBefore(today);
  }

  /// Checks if item is near expiry (within threshold days)
  ///
  /// Default threshold is 7 days but can be customized.
  ///
  /// Parameters:
  ///   - expiryDate: The expiry date to check
  ///   - thresholdDays: Number of days to consider as "near expiry" (default: 7)
  ///
  /// Returns: `true` if the item is near expiry, `false` otherwise
  bool isNearExpiry(DateTime expiryDate, {int thresholdDays = nearExpiryThresholdDays}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final daysUntilExpiry = expiry.difference(today).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= thresholdDays;
  }

  /// Checks if an expiry notification should be sent
  ///
  /// Default threshold is 3 days but can be customized.
  ///
  /// Parameters:
  ///   - expiryDate: The expiry date to check
  ///   - thresholdDays: Number of days before expiry to send notification (default: 3)
  ///
  /// Returns: `true` if a notification should be sent, `false` otherwise
  bool shouldNotifyExpiry(DateTime expiryDate, {int thresholdDays = notificationThresholdDays}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final daysUntilExpiry = expiry.difference(today).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= thresholdDays;
  }

  /// Calculates days until expiry
  ///
  /// Returns negative number if already expired.
  ///
  /// Parameters:
  ///   - expiryDate: The expiry date to check
  ///
  /// Returns: Number of days until expiry (negative if expired)
  int daysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}
