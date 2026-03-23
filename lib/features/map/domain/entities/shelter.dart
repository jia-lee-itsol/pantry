/// Domain entity representing an emergency shelter location.
///
/// This entity contains information about evacuation shelters, including
/// their geographic coordinates and address for mapping and navigation.
class Shelter {
  /// Unique identifier for the shelter
  final String id;

  /// Name of the shelter facility
  final String name;

  /// Geographic latitude coordinate
  final double latitude;

  /// Geographic longitude coordinate
  final double longitude;

  /// Street address of the shelter
  final String address;

  /// Creates a [Shelter] instance.
  ///
  /// All parameters are required to ensure complete location information.
  const Shelter({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

