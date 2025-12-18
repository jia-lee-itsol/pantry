import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/usecases/get_alerts_usecase.dart';
import '../../../../core/services/alert_service.dart';

final alertsProvider = FutureProvider<List<Alert>>((ref) async {
  final repository = ref.watch(alertRepositoryProvider);
  final useCase = GetAlertsUseCase(repository);
  return useCase();
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return ref.watch(alertServiceProvider);
});

