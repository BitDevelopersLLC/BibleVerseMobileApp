import 'dart:io' show Platform;

import 'package:flutter/material.dart';

/// Colors and typography shared across the app.
abstract final class AppTheme {
  static const _seedColor = Color(0xFF6B4E71);

  /// Light theme.
  static final ThemeData light = ThemeData(colorSchemeSeed: _seedColor);

  /// Dark theme, used when the phone is in dark mode.
  static final ThemeData dark = ThemeData(colorSchemeSeed: _seedColor, brightness: Brightness.dark);

  /// A serif font that ships with the operating system, so no font is ever downloaded.
  static String get serifFontFamily => Platform.isIOS ? 'Georgia' : 'serif';
}
