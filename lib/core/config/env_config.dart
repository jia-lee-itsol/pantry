import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration
///
/// Manages access to environment variables loaded from .env file.
/// Provides API keys and configuration values needed by various services.
///
/// Environment variables should be defined in a .env file at the project root.
///
/// Required environment variables:
/// - GOOGLE_MAPS_API_KEY: For Google Maps and Places API
/// - GOOGLE_CLOUD_VISION_API_KEY: For OCR functionality
/// - CHATGPT_API_KEY: For AI features (optional)
///
/// All methods are static and the constructor is private to prevent instantiation.
class EnvConfig {
  EnvConfig._();

  /// Google Maps API Key
  ///
  /// Used for map display and location services.
  ///
  /// Returns: API key from environment or empty string if not configured
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  /// Google Places API Key
  ///
  /// Used for place searches and location autocomplete.
  /// Falls back to Google Maps API key if not separately configured.
  ///
  /// Returns: API key from environment or empty string if not configured
  static String get googlePlacesApiKey {
    return dotenv.env['GOOGLE_PLACES_API_KEY'] ??
           dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  /// ChatGPT API Key
  ///
  /// Used for AI-powered features like recipe suggestions.
  ///
  /// Returns: API key from environment or empty string if not configured
  static String get chatGptApiKey {
    return dotenv.env['CHATGPT_API_KEY'] ?? '';
  }

  /// Google Cloud Vision API Key
  ///
  /// Used for OCR (Optical Character Recognition) to scan receipts.
  ///
  /// Returns: API key from environment or empty string if not configured
  static String get googleCloudVisionApiKey {
    return dotenv.env['GOOGLE_CLOUD_VISION_API_KEY'] ?? '';
  }

  /// Checks if environment is properly configured
  ///
  /// Verifies that at least the essential Google Maps API key is present.
  ///
  /// Returns: `true` if configuration is valid, `false` otherwise
  static bool get isConfigured {
    return googleMapsApiKey.isNotEmpty;
  }
}

