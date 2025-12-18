import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  /// Google Maps API Key
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  /// Google Places API Key
  static String get googlePlacesApiKey {
    return dotenv.env['GOOGLE_PLACES_API_KEY'] ?? 
           dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  /// ChatGPT API Key
  static String get chatGptApiKey {
    return dotenv.env['CHATGPT_API_KEY'] ?? '';
  }

  /// 환경 변수가 제대로 로드되었는지 확인
  static bool get isConfigured {
    return googleMapsApiKey.isNotEmpty;
  }
}

