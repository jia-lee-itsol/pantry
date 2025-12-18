import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._();

  /// 위치 및 카메라 권한 요청
  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    try {
      final permissions = [
        Permission.location,
        Permission.camera,
        Permission.photos, // iOS에서 사진 라이브러리 접근용
      ];

      final statuses = await permissions.request();
      return statuses;
    } catch (e) {
      // MissingPluginException 등 에러 발생 시 빈 맵 반환
      return {};
    }
  }

  /// 위치 권한 확인
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// 카메라 권한 확인
  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// 위치 권한 요청
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// 카메라 권한 요청
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 사진 라이브러리 권한 요청 (iOS)
  static Future<bool> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// 위치 권한이 영구적으로 거부되었는지 확인
  static Future<bool> isLocationPermanentlyDenied() async {
    final status = await Permission.location.status;
    return status.isPermanentlyDenied;
  }

  /// 카메라 권한이 영구적으로 거부되었는지 확인
  static Future<bool> isCameraPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// 설정 앱 열기
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
