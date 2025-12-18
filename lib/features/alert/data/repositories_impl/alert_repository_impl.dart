import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_local_datasource.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertDataSource dataSource;

  AlertRepositoryImpl(this.dataSource);

  @override
  Future<List<Alert>> getAlerts() async {
    return await dataSource.getAlerts();
  }

  @override
  Future<void> markAsRead(String alertId) async {
    await dataSource.markAsRead(alertId);
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    await dataSource.deleteAlert(alertId);
  }
}

