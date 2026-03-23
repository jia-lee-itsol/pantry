import 'dart:developer' as developer;

/// Application Logger
///
/// Provides structured logging functionality for the application.
/// Uses Dart's developer.log for better integration with debugging tools.
///
/// All methods are static and the constructor is private to prevent instantiation.
///
/// Log Levels:
/// - Debug (700): Detailed debugging information
/// - Info (800): General informational messages
/// - Warning (900): Warning messages for potential issues
/// - Error (1000): Error messages for failures
class AppLogger {
  AppLogger._();

  /// Logs a debug message
  ///
  /// Use for detailed debugging information that helps track application flow.
  ///
  /// Parameters:
  ///   - message: The debug message to log
  ///   - tag: Optional tag for categorizing logs (defaults to 'AppLogger')
  static void debug(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 700, // LogLevel.debug
    );
  }

  /// Logs an info message
  ///
  /// Use for general informational messages about application state.
  ///
  /// Parameters:
  ///   - message: The info message to log
  ///   - tag: Optional tag for categorizing logs (defaults to 'AppLogger')
  static void info(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 800, // LogLevel.info
    );
  }

  /// Logs a warning message
  ///
  /// Use for warning messages about potential issues that don't prevent operation.
  ///
  /// Parameters:
  ///   - message: The warning message to log
  ///   - tag: Optional tag for categorizing logs (defaults to 'AppLogger')
  static void warning(String message, [String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 900, // LogLevel.warning
    );
  }

  /// Logs an error message
  ///
  /// Use for error messages when operations fail.
  ///
  /// Parameters:
  ///   - message: The error message to log
  ///   - error: Optional error object for additional context
  ///   - tag: Optional tag for categorizing logs (defaults to 'AppLogger')
  static void error(String message, [Object? error, String? tag]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      level: 1000, // LogLevel.error
      error: error,
    );
  }
}

