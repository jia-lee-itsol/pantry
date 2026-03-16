/// Use Case for checking expiry-related business rules.
/// Contains business rules for expiry notifications and warnings.
class CheckExpiryUseCase {
  static const int notificationThresholdDays = 3;
  static const int nearExpiryThresholdDays = 7;

  /// Check if item expires today.
  bool isExpiredToday(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry == today;
  }

  /// Check if item is expired (past due).
  bool isExpired(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.isBefore(today);
  }

  /// Check if item is near expiry (within threshold days).
  bool isNearExpiry(DateTime expiryDate, {int thresholdDays = nearExpiryThresholdDays}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final daysUntilExpiry = expiry.difference(today).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= thresholdDays;
  }

  /// Check if item should trigger expiry notification (within notification threshold).
  bool shouldNotifyExpiry(DateTime expiryDate, {int thresholdDays = notificationThresholdDays}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final daysUntilExpiry = expiry.difference(today).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= thresholdDays;
  }

  /// Get days until expiry.
  int daysUntilExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}
