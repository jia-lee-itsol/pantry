import '../entities/shelter.dart';

abstract class MapRepository {
  Future<List<Shelter>> getNearbyShelters(double latitude, double longitude);
  Future<List<Shelter>> getAllShelters();
}

