import Foundation

/// The user's choices, shared between the app, the lock screen widget and the Shortcuts action.
///
/// The Flutter app owns these settings. Whenever they change, `AppDelegate` copies them into the
/// App Group's user defaults, the only storage the widget extension can read. Nothing here ever
/// leaves the device.
enum SharedSettings {
  /// The App Group both targets belong to. It must match the App Groups capability of the
  /// Runner and VerseWidgetExtension targets (`Runner.entitlements`, `VerseWidgetExtension.entitlements`).
  static let appGroup = "group.app.withoutprice"

  /// Keys in the App Group's user defaults. The values are the ids the Dart code uses.
  enum Key {
    /// Translation code, for example "BSB".
    static let translation = "translation"
    /// `WallpaperStyle` id, for example "dawn".
    static let style = "style"
    /// `VersePosition` id, for example "bottom".
    static let position = "position"
    /// `VerseCadence` id: "daily" or "hourly".
    static let cadence = "cadence"
  }

  /// Translation used until the user picks one. Matches `VerseLibrary.defaultTranslationId` (Dart).
  static let defaultTranslationId = "BSB"

  /// The App Group's user defaults, or `nil` if the target is missing the App Groups capability.
  static var defaults: UserDefaults? {
    UserDefaults(suiteName: appGroup)
  }

  /// The chosen translation code.
  static var translationId: String {
    defaults?.string(forKey: Key.translation) ?? defaultTranslationId
  }

  /// The chosen wallpaper background.
  static var style: WallpaperStyle {
    WallpaperStyle(id: defaults?.string(forKey: Key.style))
  }

  /// Where the verse sits on the wallpaper.
  static var position: VersePosition {
    VersePosition(id: defaults?.string(forKey: Key.position))
  }

  /// How often a new verse appears.
  static var cadence: VerseCadence {
    VerseCadence(id: defaults?.string(forKey: Key.cadence))
  }
}
