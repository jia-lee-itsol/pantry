import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 이미지 캐싱 서비스
/// OCR 스캔 이미지 및 기타 이미지 파일을 캐시하여 성능을 최적화합니다.
class ImageCacheService {
  static const String _cacheDirName = 'image_cache';
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const int _maxCacheAge = 7 * 24 * 60 * 60; // 7일

  /// 이미지를 캐시 디렉토리에 복사
  Future<String?> cacheImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      final cacheDir = await _getCacheDirectory();
      if (cacheDir == null) return null;

      final fileName = path.basename(sourcePath);
      final cachedPath = path.join(cacheDir.path, fileName);

      // 이미 캐시되어 있으면 기존 파일 경로 반환
      final cachedFile = File(cachedPath);
      if (await cachedFile.exists()) {
        return cachedPath;
      }

      // 캐시 크기 확인 및 정리
      await _cleanCacheIfNeeded(cacheDir);

      // 이미지 복사
      await sourceFile.copy(cachedPath);
      return cachedPath;
    } catch (e) {
      return null;
    }
  }

  /// 캐시된 이미지 경로 가져오기
  Future<String?> getCachedImagePath(String fileName) async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (cacheDir == null) return null;

      final cachedPath = path.join(cacheDir.path, fileName);
      final cachedFile = File(cachedPath);

      if (await cachedFile.exists()) {
        return cachedPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 캐시 디렉토리 가져오기
  Future<Directory?> _getCacheDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory(path.join(appDir.path, _cacheDirName));

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      return cacheDir;
    } catch (e) {
      return null;
    }
  }

  /// 캐시 크기 확인 및 정리
  Future<void> _cleanCacheIfNeeded(Directory cacheDir) async {
    try {
      final files = await cacheDir.list().toList();
      int totalSize = 0;
      final fileInfos = <_FileInfo>[];

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileInfos.add(_FileInfo(
            path: file.path,
            size: stat.size,
            modified: stat.modified,
          ));
        }
      }

      // 캐시 크기가 제한을 초과하면 오래된 파일부터 삭제
      if (totalSize > _maxCacheSize) {
        fileInfos.sort((a, b) => a.modified.compareTo(b.modified));

        for (final fileInfo in fileInfos) {
          if (totalSize <= _maxCacheSize * 0.8) break; // 80%까지 줄임

          final file = File(fileInfo.path);
          if (await file.exists()) {
            await file.delete();
            totalSize -= fileInfo.size;
          }
        }
      }

      // 오래된 파일 삭제 (7일 이상)
      final now = DateTime.now();
      for (final fileInfo in fileInfos) {
        final age = now.difference(fileInfo.modified).inSeconds;
        if (age > _maxCacheAge) {
          final file = File(fileInfo.path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // 캐시 정리 실패는 무시
    }
  }

  /// 모든 캐시 삭제
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (cacheDir != null && await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      // 캐시 삭제 실패는 무시
    }
  }

  /// 캐시 크기 가져오기
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (cacheDir == null) return 0;

      int totalSize = 0;
      await for (final file in cacheDir.list()) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

class _FileInfo {
  final String path;
  final int size;
  final DateTime modified;

  _FileInfo({
    required this.path,
    required this.size,
    required this.modified,
  });
}

