import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_nearby_shelters_usecase.dart';
import '../../domain/usecases/get_all_shelters_usecase.dart';
import '../../../../core/services/map_service.dart';

// Repository Provider (uses core service)
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return ref.watch(mapServiceProvider);
});

// UseCase Providers
final getNearbySheltersUseCaseProvider = Provider<GetNearbySheltersUseCase>((ref) {
  final repository = ref.watch(mapRepositoryProvider);
  return GetNearbySheltersUseCase(repository);
});

final getAllSheltersUseCaseProvider = Provider<GetAllSheltersUseCase>((ref) {
  final repository = ref.watch(mapRepositoryProvider);
  return GetAllSheltersUseCase(repository);
});

// Nearby Shelters Provider (uses UseCase)
final nearbySheltersProvider =
    FutureProvider.family<List<Shelter>, Map<String, double>>((ref, params) async {
  final useCase = ref.watch(getNearbySheltersUseCaseProvider);
  return useCase(params['latitude']!, params['longitude']!);
});

// All Shelters Provider (uses UseCase)
final allSheltersProvider = FutureProvider<List<Shelter>>((ref) async {
  final useCase = ref.watch(getAllSheltersUseCaseProvider);
  return useCase();
});
