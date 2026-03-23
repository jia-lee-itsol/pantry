import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'typography.dart';

/// Application Theme
///
/// Provides the centralized theme configuration for the application.
/// Uses Material Design 3 with custom color schemes and typography.
///
/// All methods are static and the constructor is private to prevent instantiation.
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  ///
  /// Returns a ThemeData configured for light mode with:
  /// - Material Design 3 enabled
  /// - Custom color scheme (pastel green palette)
  /// - Custom typography
  /// - Styled components (AppBar, Buttons, Cards, Inputs)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.light,
      textTheme: AppTypography.textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColorSchemes.light.surface,
        foregroundColor: AppColorSchemes.light.onSurface,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColorSchemes.light.onSurface,
        ),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColorSchemes.light.outlineVariant,
            width: 1,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorSchemes.light.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColorSchemes.light.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColorSchemes.light.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColorSchemes.light.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

