import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Image Cache Service
///
/// Manages image caching to optimize performance for OCR scanned images
/// and other image files. This service handles automatic cache cleanup
/// based on size and age constraints.
///
/// Cache Constraints:
/// - Maximum cache size: 50MB
/// - Maximum cache age: 7 days
/// - Automatic cleanup when limits are exceeded
class ImageCacheService {
  static const String _cacheDirName = 'image_cache';
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const int _maxCacheAge = 7 * 24 * 60 * 60; // 7 days in seconds

  /// Copies an image to the cache directory
  ///
  /// If the image already exists in cache, returns the existing path.
  /// Automatically checks cache size and cleans up old files if needed.
  ///
  /// Parameters:
  ///   - sourcePath: The file path of the source image to cache
  ///
  /// Returns: The cached image path if successful, null otherwise
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

  /// Gets the cached image path
  ///
  /// Retrieves the file path for a cached image by its filename.
  ///
  /// Parameters:
  ///   - fileName: The name of the cached image file
  ///
  /// Returns: The cached image path if it exists, null otherwise
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

  /// Gets the cache directory
  ///
  /// Creates the cache directory if it doesn't exist.
  ///
  /// Returns: The cache directory if successful, null otherwise
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

  /// Checks cache size and cleans up if needed
  ///
  /// This method performs two types of cleanup:
  /// 1. Size-based: If total cache size exceeds the limit, deletes oldest files
  ///    until cache is reduced to 80% of the maximum size
  /// 2. Age-based: Deletes files older than 7 days
  ///
  /// Parameters:
  ///   - cacheDir: The cache directory to clean
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

      // Delete old files if cache size exceeds limit
      if (totalSize > _maxCacheSize) {
        fileInfos.sort((a, b) => a.modified.compareTo(b.modified));

        for (final fileInfo in fileInfos) {
          if (totalSize <= _maxCacheSize * 0.8) break; // Reduce to 80%

          final file = File(fileInfo.path);
          if (await file.exists()) {
            await file.delete();
            totalSize -= fileInfo.size;
          }
        }
      }

      // Delete files older than 7 days
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
      // Ignore cache cleanup failures
    }
  }

  /// Clears all cached images
  ///
  /// Deletes the entire cache directory and all its contents.
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

  /// Gets the total size of the cache
  ///
  /// Calculates and returns the total size in bytes of all cached files.
  ///
  /// Returns: Total cache size in bytes, or 0 if unable to calculate
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

/// Internal class for tracking cached file metadata
///
/// Used for cache cleanup operations to sort and manage files
/// based on size and modification date.
class _FileInfo {
  /// The file path
  final String path;

  /// The file size in bytes
  final int size;

  /// The last modification date
  final DateTime modified;

  _FileInfo({
    required this.path,
    required this.size,
    required this.modified,
  });
}

