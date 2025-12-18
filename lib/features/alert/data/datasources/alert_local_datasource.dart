import '../models/alert_model.dart';

abstract class AlertDataSource {
  Future<List<AlertModel>> getAlerts();
  Future<void> markAsRead(String alertId);
  Future<void> deleteAlert(String alertId);
}

