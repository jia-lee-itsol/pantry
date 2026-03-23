import '../models/alert_model.dart';

/// Abstract data source interface for alert data operations.
///
/// This interface defines the contract for accessing alert data from
/// various sources (local database, remote API, etc.). Concrete implementations
/// provide the actual data access logic.
abstract class AlertDataSource {
  /// Fetches all alerts from the data source.
  ///
  /// Returns a list of [AlertModel] objects.
  /// Throws an exception if the operation fails.
  Future<List<AlertModel>> getAlerts();

  /// Marks an alert as read in the data source.
  ///
  /// Parameters:
  ///   [alertId] - The unique identifier of the alert to mark as read
  ///
  /// Throws an exception if the operation fails.
  Future<void> markAsRead(String alertId);

  /// Deletes an alert from the data source.
  ///
  /// Parameters:
  ///   [alertId] - The unique identifier of the alert to delete
  ///
  /// Throws an exception if the operation fails.
  Future<void> deleteAlert(String alertId);
}

