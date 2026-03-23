import 'package:flutter/material.dart';

/// Application Color Schemes
///
/// Defines the color palettes used throughout the application.
/// Uses a pastel green theme that's soft and easy on the eyes,
/// suitable for a pantry/food management application.
///
/// All methods are static and the constructor is private to prevent instantiation.
class AppColorSchemes {
  AppColorSchemes._();

  /// Light color scheme
  ///
  /// A soft, nature-inspired palette with pastel greens and neutral tones.
  ///
  /// Color Palette:
  /// - Primary: Pastel Green (#6B8E5A) - Main brand color
  /// - Secondary: Light Green (#9BB5A0) - Supporting color
  /// - Tertiary: Beige (#B5A58F) - Accent color
  /// - Surface: White (#FFFFFF) - Background color
  /// - Error: Red (#D32F2F) - Error states
  static const ColorScheme light = ColorScheme.light(
    primary: Color(0xFF6B8E5A), // Pastel Green
    primaryContainer: Color(0xFFE8F5E3),
    secondary: Color(0xFF9BB5A0), // Secondary Green
    secondaryContainer: Color(0xFFF0F7F2),
    tertiary: Color(0xFFB5A58F), // Beige
    surface: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFF5F5F5),
    error: Color(0xFFD32F2F),
    errorContainer: Color(0xFFFFEBEE),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1C1C1C),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFE0E0E0),
    outlineVariant: Color(0xFFF0F0F0),
  );
}
