import '../entities/shelter.dart';
import '../repositories/map_repository.dart';

class GetAllSheltersUseCase {
  final MapRepository repository;

  GetAllSheltersUseCase(this.repository);

  Future<List<Shelter>> call() {
    return repository.getAllShelters();
  }
}
