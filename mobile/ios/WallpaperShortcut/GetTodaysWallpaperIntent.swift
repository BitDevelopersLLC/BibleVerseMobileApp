import AppIntents
import UIKit
import UniformTypeIdentifiers

/// The "Get Today's Wallpaper" action in the Shortcuts app.
///
/// iOS doesn't let apps change the wallpaper, but Shortcuts can. A personal automation runs
/// this action every morning and passes the image to Apple's "Set Wallpaper Photo" action, so
/// the lock screen shows a new full-screen verse without the user doing anything.
///
/// The action returns the current verse (see `VerseStore`) drawn with the translation,
/// background and verse position chosen in the app. It runs in the background, never opens the
/// app, and works offline. The setup steps users follow are in
/// `lib/ui/screens/iphone_setup_screen.dart` and on https://withoutprice.app/support.html.
@available(iOS 17.0, *)
struct GetTodaysWallpaperIntent: AppIntent {
  static let title: LocalizedStringResource = "Get Today's Wallpaper"

  static let description = IntentDescription(
    """
    Makes a full-screen picture of the current verse, using the translation, background and \
    verse position you chose in Without Price. Pass it to "Set Wallpaper Photo" to change your \
    lock screen every day.
    """,
    categoryName: "Wallpaper"
  )

  /// The image is made in the background; there is nothing to show in the app.
  static let openAppWhenRun = false

  func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
    guard let verse = VerseStore.verse(at: .now) else {
      throw WallpaperIntentError.versesUnavailable
    }
    let pixelSize = await Self.portraitScreenPixelSize()
    guard let png = WallpaperRenderer.pngData(for: verse, pixelSize: pixelSize) else {
      throw WallpaperIntentError.renderingFailed
    }
    let file = IntentFile(data: png, filename: "without-price-\(verse.id).png", type: .png)
    return .result(value: file)
  }

  /// The device's full screen size in pixels, in portrait orientation.
  @MainActor
  private static func portraitScreenPixelSize() -> CGSize {
    // `nativeBounds` is always reported for the portrait-up orientation, in pixels.
    let native = UIScreen.main.nativeBounds.size
    return CGSize(width: min(native.width, native.height), height: max(native.width, native.height))
  }
}

/// Errors the Shortcuts action can report. Shortcuts shows the message to the user.
@available(iOS 17.0, *)
enum WallpaperIntentError: Error, CustomLocalizedStringResourceConvertible {
  /// The bundled verse data is missing or unreadable (a broken build).
  case versesUnavailable
  /// The image could not be drawn or encoded.
  case renderingFailed

  var localizedStringResource: LocalizedStringResource {
    switch self {
    case .versesUnavailable:
      "Without Price couldn't read its verses. Please reinstall the app."
    case .renderingFailed:
      "Without Price couldn't make the wallpaper picture. Please try again."
    }
  }
}
