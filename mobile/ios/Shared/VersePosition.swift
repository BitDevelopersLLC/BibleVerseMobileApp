import CoreGraphics

/// Where the verse sits on the wallpaper, in four vertical areas of the screen.
///
/// The ids and fractions are duplicated in `lib/wallpaper/verse_position.dart` (Dart) and
/// `VersePosition.kt` (Android). Keep all three in sync.
enum VersePosition: String {
  /// The top quarter (0-25%). Starts below the status bar.
  case top
  /// The second quarter (25-50%).
  case upperMiddle
  /// The third quarter (50-75%).
  case lowerMiddle
  /// The bottom quarter (75-100%). Ends above the home indicator.
  case bottom

  /// The position with `id`, or `.bottom` (the app's default) if there is no match.
  init(id: String?) {
    self = id.flatMap(VersePosition.init(rawValue:)) ?? .bottom
  }

  /// Top of the area the verse is centered in, as a fraction of the screen height.
  var bandTop: CGFloat {
    switch self {
    case .top: 0.08
    case .upperMiddle: 0.26
    case .lowerMiddle: 0.51
    case .bottom: 0.76
    }
  }

  /// Bottom of that area, as a fraction of the screen height.
  var bandBottom: CGFloat {
    switch self {
    case .top: 0.25
    case .upperMiddle: 0.49
    case .lowerMiddle: 0.74
    case .bottom: 0.90
    }
  }
}
