/// Types of alerts that can be generated in the application.
enum AlertType {
  /// Alert for items nearing or past their expiration date
  expiry,

  /// Alert for low stock or inventory issues
  stock,

  /// Alert for member joining/leaving notifications
  member,
}

/// Domain entity representing a user notification or alert.
///
/// This entity encapsulates all information about an alert shown to users,
/// including its type, content, timestamps, and read status.
class Alert {
  /// Unique identifier for the alert
  final String id;

  /// The type of alert (expiry, stock, or member)
  final AlertType type;

  /// Title or heading of the alert
  final String title;

  /// Detailed message content of the alert
  final String message;

  /// Timestamp when the alert was created
  final DateTime createdAt;

  /// Whether the alert has been read by the user
  final bool isRead;

  /// Creates an [Alert] instance.
  ///
  /// All parameters are required except [isRead] which defaults to false.
  const Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}

