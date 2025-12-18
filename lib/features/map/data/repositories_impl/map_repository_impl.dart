import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Shelter>> getNearbyShelters(
      double latitude, double longitude) async {
    return await remoteDataSource.getNearbyShelters(latitude, longitude);
  }

  @override
  Future<List<Shelter>> getAllShelters() async {
    return await remoteDataSource.getAllShelters();
  }
}

