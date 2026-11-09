import 'package:flutter/services.dart';

import '../data/verse_cadence.dart';
import '../wallpaper/verse_position.dart';
import '../wallpaper/wallpaper_style.dart';

/// Dart side of the `app.withoutprice/lockscreen` method channel.
///
/// * Android (`LockScreenChannel.kt`): the native code sets the lock screen wallpaper
///   itself and refreshes it in the background whenever a new verse is due.
/// * iOS (`AppDelegate.swift`): the native code shares the choices with the lock screen
///   widget and the Shortcuts action through the app's App Group.
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
  /// On Android, [enabled] starts or stops the wallpaper job, which redraws the lock screen
  /// whenever [cadence] brings a new verse.
  /// On iOS, the widget and the "Get Today's Wallpaper" Shortcuts action read all of the
  /// choices from the App Group; [enabled] is ignored.
  static Future<void> configure({
    required bool enabled,
    required String translationId,
    required WallpaperStyle style,
    required VersePosition position,
    required VerseCadence cadence,
  }) => _invoke('configure', {
    'enabled': enabled,
    'translation': translationId,
    'style': style.name,
    'position': position.name,
    'cadence': cadence.name,
  });

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
