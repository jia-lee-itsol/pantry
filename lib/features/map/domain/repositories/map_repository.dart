import '../entities/shelter.dart';

/// Repository interface for map and shelter location operations.
///
/// This repository defines the contract for finding emergency shelters,
/// either nearby a specific location or retrieving all available shelters.
abstract class MapRepository {
  /// Finds emergency shelters near a specific geographic location.
  ///
  /// Searches for shelters within a defined radius of the given coordinates,
  /// typically using map APIs or location services.
  ///
  /// Parameters:
  ///   [latitude] - The latitude coordinate of the search center
  ///   [longitude] - The longitude coordinate of the search center
  ///
  /// Returns a list of [Shelter] objects within range of the location.
  /// Throws an exception if the search fails.
  Future<List<Shelter>> getNearbyShelters(double latitude, double longitude);

  /// Retrieves all available emergency shelters.
  ///
  /// Returns a complete list of all shelters in the database or region.
  /// Throws an exception if the operation fails.
  Future<List<Shelter>> getAllShelters();
}

