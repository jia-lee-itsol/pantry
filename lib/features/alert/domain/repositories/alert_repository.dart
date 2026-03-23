import '../entities/alert.dart';

/// Repository interface for managing user alerts and notifications.
///
/// This repository defines the contract for alert-related operations,
/// including retrieving alerts, marking them as read, and deleting them.
/// Implementations handle data persistence logic.
abstract class AlertRepository {
  /// Retrieves all alerts for the current user.
  ///
  /// Returns a list of [Alert] objects ordered by creation date.
  /// Throws an exception if the operation fails.
  Future<List<Alert>> getAlerts();

  /// Marks a specific alert as read.
  ///
  /// Parameters:
  ///   [alertId] - The unique identifier of the alert to mark as read
  ///
  /// Throws an exception if the alert is not found or the operation fails.
  Future<void> markAsRead(String alertId);

  /// Deletes a specific alert from the system.
  ///
  /// Parameters:
  ///   [alertId] - The unique identifier of the alert to delete
  ///
  /// Throws an exception if the alert is not found or the operation fails.
  Future<void> deleteAlert(String alertId);
}

