import '../entities/alert.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlerts();
  Future<void> markAsRead(String alertId);
  Future<void> deleteAlert(String alertId);
}

