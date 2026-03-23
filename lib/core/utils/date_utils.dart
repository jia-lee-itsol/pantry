import 'package:intl/intl.dart';

/// Date Utilities
///
/// Provides utility methods for date and time formatting.
/// All methods are static and the constructor is private to prevent instantiation.
class DateUtils {
  DateUtils._();

  /// Formats a date to 'yyyy-MM-dd' format
  ///
  /// Parameters:
  ///   - date: The DateTime to format
  ///
  /// Returns: Formatted date string (e.g., "2024-12-25")
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formats a date and time to 'yyyy-MM-dd HH:mm' format
  ///
  /// Parameters:
  ///   - date: The DateTime to format
  ///
  /// Returns: Formatted datetime string (e.g., "2024-12-25 14:30")
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}

