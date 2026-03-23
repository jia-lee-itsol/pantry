import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shelter_model.dart';
import 'map_remote_datasource.dart';
import '../../../../core/config/env_config.dart';

/// Data source for finding shelters using Google Places API.
///
/// This class uses Google Places API to search for emergency shelters
/// (evacuation centers) near a given location. It searches using Japanese
/// keywords and returns shelter information with coordinates.
class MapGooglePlacesDataSource implements MapRemoteDataSource {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _textSearchEndpoint = '/textsearch/json';
  static const int _radius = 5000; // Search radius: 5km

  /// Searches for nearby emergency shelters using Google Places API.
  ///
  /// Performs a text search for "避難所" (evacuation shelter in Japanese)
  /// within a 5km radius of the specified coordinates.
  ///
  /// Parameters:
  ///   [latitude] - The latitude coordinate of the search center
  ///   [longitude] - The longitude coordinate of the search center
  ///
  /// Returns a list of [ShelterModel] objects found near the location.
  /// Throws an exception if the API key is missing or the request fails.
  @override
  Future<List<ShelterModel>> getNearbyShelters(
    double latitude,
    double longitude,
  ) async {
    try {
      final apiKey = EnvConfig.googlePlacesApiKey;
      if (apiKey.isEmpty) {
        throw Exception('Google Places API Key is not configured.');
      }

      // Search for "避難所" (evacuation shelter in Japanese)
      final query = '避難所';
      final url = Uri.parse(
        '$_baseUrl$_textSearchEndpoint?query=$query&location=$latitude,$longitude&radius=$_radius&language=ja&key=$apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final results = data['results'] as List<dynamic>? ?? [];
          return results.map((result) {
            final location = result['geometry']['location'];
            return ShelterModel(
              id: result['place_id'] as String,
              name: result['name'] as String,
              latitude: (location['lat'] as num).toDouble(),
              longitude: (location['lng'] as num).toDouble(),
              address: result['formatted_address'] as String? ?? 
                      result['vicinity'] as String? ?? '',
            );
          }).toList();
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Shelter search failed: $e');
    }
  }

  /// Retrieves all shelters (not location-specific).
  ///
  /// Currently returns an empty list as all-shelter search requires
  /// a location context. Can be implemented differently if needed.
  ///
  /// Returns an empty list.
  @override
  Future<List<ShelterModel>> getAllShelters() async {
    // All-shelter search requires current location, so return empty list
    // Can be implemented using alternative methods if needed
    return [];
  }
}

