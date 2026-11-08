import 'dart:ui';

/// A background for the verse wallpaper and the home screen widget.
///
/// The ids ([name]) and colors are duplicated in `WallpaperStyle.kt` (Android) and
/// `WidgetStyle.swift` (iOS widget). Keep all three in sync.
enum WallpaperStyle {
  /// Warm purple fading to peach.
  dawn('Dawn', Color(0xFF3B2A4D), Color(0xFFC9826B), Color(0xFFFFFFFF)),

  /// Deep navy.
  night('Night', Color(0xFF0B1426), Color(0xFF22365C), Color(0xFFF2EEE4)),

  /// Dark olive green.
  olive('Olive', Color(0xFF1F2A1C), Color(0xFF5C6B3E), Color(0xFFF4F1E6)),

  /// Neutral charcoal.
  stone('Stone', Color(0xFF2B2B2B), Color(0xFF575350), Color(0xFFFFFFFF));

  const WallpaperStyle(this.label, this.topColor, this.bottomColor, this.textColor);

  /// Name shown in the style picker.
  final String label;

  /// Gradient color at the top of the screen.
  final Color topColor;

  /// Gradient color at the bottom of the screen.
  final Color bottomColor;

  /// Color of the verse text.
  final Color textColor;

  /// The style whose [name] is [id], or [dawn] if there is no match.
  static WallpaperStyle fromId(String? id) =>
      values.firstWhere((style) => style.name == id, orElse: () => dawn);
}
