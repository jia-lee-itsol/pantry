import 'package:flutter/material.dart';

/// Application Typography
///
/// Defines the text styles used throughout the application.
/// Follows Material Design 3 typography guidelines with custom sizing
/// and weight configurations.
///
/// Text Style Categories:
/// - Headlines: Large, bold text for major headings
/// - Titles: Medium-weight text for section headings
/// - Body: Regular text for content
/// - Labels: Medium-weight text for UI elements like buttons
///
/// All methods are static and the constructor is private to prevent instantiation.
class AppTypography {
  AppTypography._();

  /// Application text theme
  ///
  /// Provides a complete set of text styles following Material Design 3.
  static const TextTheme textTheme = TextTheme(
    // Headlines - Large, bold text for major headings
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.3,
      letterSpacing: -0.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),

    // Titles - Medium-weight text for section headings
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),

    // Body - Regular text for content
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),

    // Labels - Medium-weight text for UI elements
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
  );
}

