import '../models/shelter_model.dart';

abstract class MapRemoteDataSource {
  Future<List<ShelterModel>> getNearbyShelters(
      double latitude, double longitude);
  Future<List<ShelterModel>> getAllShelters();
}

