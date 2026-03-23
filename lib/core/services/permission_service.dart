import 'package:permission_handler/permission_handler.dart';

/// Permission Service
///
/// Manages runtime permissions for the application using the permission_handler package.
/// This service provides methods to request and check various permissions required
/// by the app, including location, camera, and photo library access.
///
/// All methods are static and the constructor is private to prevent instantiation.
class PermissionService {
  PermissionService._();

  /// Requests all necessary permissions
  ///
  /// Requests location, camera, and photo library permissions simultaneously.
  /// This is typically called during app initialization or onboarding.
  ///
  /// Returns: Map of permissions to their status after the request
  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    try {
      final permissions = [
        Permission.location,
        Permission.camera,
        Permission.photos, // For photo library access on iOS
      ];

      final statuses = await permissions.request();
      return statuses;
    } catch (e) {
      // Return empty map if error occurs (e.g., MissingPluginException)
      return {};
    }
  }

  /// Checks if location permission is granted
  ///
  /// Returns: `true` if location permission is granted, `false` otherwise
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Checks if camera permission is granted
  ///
  /// Returns: `true` if camera permission is granted, `false` otherwise
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Requests location permission
  ///
  /// Returns: `true` if permission is granted after request, `false` otherwise
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Requests camera permission
  ///
  /// Returns: `true` if permission is granted after request, `false` otherwise
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Requests photo library permission (iOS)
  ///
  /// Returns: `true` if permission is granted after request, `false` otherwise
  static Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Checks if photo library permission is granted
  ///
  /// Returns: `true` if photo library permission is granted, `false` otherwise
  static Future<bool> checkPhotoLibraryPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Checks if photo library permission is permanently denied
  ///
  /// Returns: `true` if permission is permanently denied, `false` otherwise
  static Future<bool> isPhotoLibraryPermanentlyDenied() async {
    final status = await Permission.photos.status;
    return status.isPermanentlyDenied;
  }

  /// Checks if location permission is permanently denied
  ///
  /// Returns: `true` if permission is permanently denied, `false` otherwise
  static Future<bool> isLocationPermanentlyDenied() async {
    final status = await Permission.location.status;
    return status.isPermanentlyDenied;
  }

  /// Checks if camera permission is permanently denied
  ///
  /// Returns: `true` if permission is permanently denied, `false` otherwise
  static Future<bool> isCameraPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Checks if settings must be opened for camera permission
  ///
  /// On iOS, once a permission is denied, it cannot be re-requested
  /// and the user must go to Settings to change it.
  ///
  /// Returns: `true` if user must open settings to change permission
  static Future<bool> shouldOpenSettingsForCamera() async {
    final status = await Permission.camera.status;
    return status.isDenied || status.isPermanentlyDenied;
  }

  /// Checks if settings must be opened for photo library permission
  ///
  /// Returns: `true` if user must open settings to change permission
  static Future<bool> shouldOpenSettingsForPhotoLibrary() async {
    final status = await Permission.photos.status;
    return status.isDenied || status.isPermanentlyDenied;
  }

  /// Opens the app settings page
  ///
  /// This allows the user to manually change permissions in the device settings.
  ///
  /// Returns: `true` if settings were opened successfully, `false` otherwise
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
