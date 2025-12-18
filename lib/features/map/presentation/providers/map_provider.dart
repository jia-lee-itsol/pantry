import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_nearby_shelters_usecase.dart';
import '../../../../core/services/map_service.dart';

final nearbySheltersProvider =
    FutureProvider.family<List<Shelter>, Map<String, double>>((ref, params) {
  final repository = ref.watch(mapRepositoryProvider);
  final useCase = GetNearbySheltersUseCase(repository);
  return useCase(params['latitude']!, params['longitude']!);
});

final allSheltersProvider = FutureProvider<List<Shelter>>((ref) async {
  final repository = ref.watch(mapRepositoryProvider);
  return repository.getAllShelters();
});

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return ref.watch(mapServiceProvider);
});

