import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../domain/usecases/get_nearby_shelters_usecase.dart';
import '../../domain/usecases/get_all_shelters_usecase.dart';
import '../../../../core/services/map_service.dart';

/// Provider for the map repository.
///
/// Exposes the [MapRepository] interface, implemented by the core
/// map service. Enables dependency injection for shelter search operations.
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return ref.watch(mapServiceProvider);
});

/// Provider for the get nearby shelters use case.
///
/// Creates an instance of [GetNearbySheltersUseCase] with the injected
/// map repository, following clean architecture principles.
final getNearbySheltersUseCaseProvider = Provider<GetNearbySheltersUseCase>((ref) {
  final repository = ref.watch(mapRepositoryProvider);
  return GetNearbySheltersUseCase(repository);
});

/// Provider for the get all shelters use case.
///
/// Creates an instance of [GetAllSheltersUseCase] for retrieving all
/// available shelter locations.
final getAllSheltersUseCaseProvider = Provider<GetAllSheltersUseCase>((ref) {
  final repository = ref.watch(mapRepositoryProvider);
  return GetAllSheltersUseCase(repository);
});

/// Provider for finding nearby emergency shelters.
///
/// A family provider that accepts a map of coordinates and returns
/// shelters within range. Uses the nearby shelters use case to perform
/// the search.
///
/// Parameters (in map):
///   [latitude] - The latitude coordinate
///   [longitude] - The longitude coordinate
///
/// Returns a list of [Shelter] objects near the specified location.
final nearbySheltersProvider =
    FutureProvider.family<List<Shelter>, Map<String, double>>((ref, params) async {
  final useCase = ref.watch(getNearbySheltersUseCaseProvider);
  return useCase(params['latitude']!, params['longitude']!);
});

/// Provider for all available shelters.
///
/// Retrieves all shelters regardless of location. Currently may return
/// an empty list depending on implementation.
final allSheltersProvider = FutureProvider<List<Shelter>>((ref) async {
  final useCase = ref.watch(getAllSheltersUseCaseProvider);
  return useCase();
});
