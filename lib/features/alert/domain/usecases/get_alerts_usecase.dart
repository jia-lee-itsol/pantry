import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

class GetAlertsUseCase {
  final AlertRepository repository;

  GetAlertsUseCase(this.repository);

  Future<List<Alert>> call() {
    return repository.getAlerts();
  }
}

