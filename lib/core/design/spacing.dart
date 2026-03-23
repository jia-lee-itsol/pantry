/// Application Spacing
///
/// Provides consistent spacing values used throughout the application.
/// Using a standardized spacing scale helps maintain visual consistency
/// and makes the UI easier to maintain.
///
/// Spacing Scale:
/// - xs (4px): Minimal spacing for tight layouts
/// - sm (8px): Small spacing for related elements
/// - md (16px): Standard spacing for most layouts
/// - lg (24px): Large spacing for section separation
/// - xl (32px): Extra large spacing for major sections
/// - xxl (48px): Maximum spacing for prominent sections
///
/// All values are static and the constructor is private to prevent instantiation.
class AppSpacing {
  AppSpacing._();

  /// Extra Small spacing (4px)
  static const double xs = 4.0;

  /// Small spacing (8px)
  static const double sm = 8.0;

  /// Medium spacing (16px) - Default spacing
  static const double md = 16.0;

  /// Large spacing (24px)
  static const double lg = 24.0;

  /// Extra Large spacing (32px)
  static const double xl = 32.0;

  /// Extra Extra Large spacing (48px)
  static const double xxl = 48.0;
}

