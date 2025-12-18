import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static void debug(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 700, // LogLevel.debug
    );
  }

  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 800, // LogLevel.info
    );
  }

  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 900, // LogLevel.warning
    );
  }

  static void error(String message, [Object? error, String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 1000, // LogLevel.error
      error: error,
    );
  }
}

