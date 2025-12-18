import 'package:flutter/material.dart';

class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme light = ColorScheme.light(
    primary: Color(0xFF6B8E5A), // 파스텔 그린
    primaryContainer: Color(0xFFE8F5E3),
    secondary: Color(0xFF9BB5A0), // 세컨더리 그린
    secondaryContainer: Color(0xFFF0F7F2),
    tertiary: Color(0xFFB5A58F), // 베이지
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
