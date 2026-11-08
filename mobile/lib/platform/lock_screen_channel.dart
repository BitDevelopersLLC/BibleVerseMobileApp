import 'package:flutter/services.dart';

import '../wallpaper/wallpaper_style.dart';

/// Dart side of the `app.withoutprice/lockscreen` method channel.
///
/// * Android (`LockScreenChannel.kt`): the native code sets the lock screen wallpaper
///   itself and refreshes it every day in the background.
/// * iOS (`AppDelegate.swift`): the native code shares the translation and style with the
///   lock screen widget through the app's App Group.
///
/// Every call is a no-op if the native side is missing (for example, in tests).
abstract final class LockScreenChannel {
  static const _channel = MethodChannel('app.withoutprice/lockscreen');

  /// Android: whether this device lets apps change the lock screen wallpaper.
  static Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Sends the current choices to the native side.
  ///
  /// On Android, [enabled] starts or stops the daily wallpaper job.
  /// On iOS, the widget picks up [translationId] and [style] immediately.
  static Future<void> configure({
    required bool enabled,
    required String translationId,
    required WallpaperStyle style,
  }) =>
      _invoke('configure', {'enabled': enabled, 'translation': translationId, 'style': style.name});

  /// Android: draws and sets today's verse right away instead of waiting for the next run.
  static Future<void> applyNow() => _invoke('applyNow');

  static Future<void> _invoke(String method, [Object? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // The native side isn't available on this platform or build.
    }
  }
}
