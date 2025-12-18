import '../entities/shelter.dart';
import '../repositories/map_repository.dart';

class GetNearbySheltersUseCase {
  final MapRepository repository;

  GetNearbySheltersUseCase(this.repository);

  Future<List<Shelter>> call(double latitude, double longitude) {
    return repository.getNearbyShelters(latitude, longitude);
  }
}

