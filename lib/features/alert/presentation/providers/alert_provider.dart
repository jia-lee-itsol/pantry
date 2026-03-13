import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../../../core/services/alert_service.dart';

// Repository Provider (uses core service)
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return ref.watch(alertServiceProvider);
});

// UseCase Provider
final getAlertsUseCaseProvider = Provider<GetAlertsUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return GetAlertsUseCase(repository);
});

// Alerts Provider (uses UseCase)
final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  final useCase = ref.watch(getAlertsUseCaseProvider);
  return useCase();
});
