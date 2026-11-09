import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../wallpaper/verse_position.dart';
import '../wallpaper/wallpaper_style.dart';
import 'verse_library.dart';

/// The user's choices, stored only on this device and never sent anywhere.
///
/// Listeners are notified after every change so the UI and native code stay in sync.
class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs);

  /// Reads the saved settings from device storage.
  static Future<AppSettings> load() async => AppSettings._(await SharedPreferences.getInstance());

  static const _translationKey = 'translation';
  static const _styleKey = 'style';
  static const _positionKey = 'versePosition';
  static const _dailyLockScreenKey = 'dailyLockScreen';

  final SharedPreferences _prefs;

  /// The chosen translation id, for example `BSB`.
  String get translationId =>
      _prefs.getString(_translationKey) ?? VerseLibrary.defaultTranslationId;
  set translationId(String value) => _save(_prefs.setString(_translationKey, value));

  /// The chosen wallpaper background.
  WallpaperStyle get style => WallpaperStyle.fromId(_prefs.getString(_styleKey));
  set style(WallpaperStyle value) => _save(_prefs.setString(_styleKey, value.name));

  /// Where the verse sits on the wallpaper.
  VersePosition get versePosition => VersePosition.fromId(_prefs.getString(_positionKey));
  set versePosition(VersePosition value) => _save(_prefs.setString(_positionKey, value.name));

  /// Android only: whether the app replaces the lock screen wallpaper every day.
  bool get dailyLockScreen => _prefs.getBool(_dailyLockScreenKey) ?? false;
  set dailyLockScreen(bool value) => _save(_prefs.setBool(_dailyLockScreenKey, value));

  /// [SharedPreferences] updates its in-memory cache synchronously, so listeners can be
  /// notified right away while the write to disk finishes in the background.
  void _save(Future<bool> write) {
    unawaited(write);
    notifyListeners();
  }
}
