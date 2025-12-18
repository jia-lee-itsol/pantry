import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shelter_model.dart';
import 'map_remote_datasource.dart';
import '../../../../core/config/env_config.dart';

class MapGooglePlacesDataSource implements MapRemoteDataSource {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _textSearchEndpoint = '/textsearch/json';
  static const int _radius = 5000; // 5km 반경

  @override
  Future<List<ShelterModel>> getNearbyShelters(
    double latitude,
    double longitude,
  ) async {
    try {
      final apiKey = EnvConfig.googlePlacesApiKey;
      if (apiKey.isEmpty) {
        throw Exception('Google Places API Key가 설정되지 않았습니다.');
      }

      // 일본어로 "避難所" (피난소) 검색
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
          throw Exception('Places API 오류: ${data['status']}');
        }
      } else {
        throw Exception('HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('피난소 검색 실패: $e');
    }
  }

  @override
  Future<List<ShelterModel>> getAllShelters() async {
    // 전체 피난소 검색은 현재 위치가 필요하므로 빈 리스트 반환
    // 필요시 다른 방법으로 구현 가능
    return [];
  }
}

