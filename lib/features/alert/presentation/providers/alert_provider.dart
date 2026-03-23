import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../../../core/services/alert_service.dart';

/// Provider for the alert repository.
///
/// This provider exposes the [AlertRepository] interface, which is implemented
/// by the core alert service. It enables dependency injection for alert operations.
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return ref.watch(alertServiceProvider);
});

/// Provider for the get alerts use case.
///
/// This provider creates an instance of [GetAlertsUseCase] with the injected
/// alert repository, following clean architecture principles.
final getAlertsUseCaseProvider = Provider<GetAlertsUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return GetAlertsUseCase(repository);
});

/// Provider for fetching and managing alerts.
///
/// This is a [FutureProvider] that executes the get alerts use case and
/// returns a list of [Alert] objects. It automatically handles loading,
/// error, and data states through Riverpod's AsyncValue.
final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  final useCase = ref.watch(getAlertsUseCaseProvider);
  return useCase();
});
