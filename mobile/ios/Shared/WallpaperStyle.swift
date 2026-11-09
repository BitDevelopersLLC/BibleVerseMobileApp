import SwiftUI
import UIKit

/// A background for the verse wallpaper and the home screen widget.
///
/// The ids and colors are duplicated in `lib/wallpaper/wallpaper_style.dart` (Dart) and
/// `WallpaperStyle.kt` (Android). Keep all three in sync.
enum WallpaperStyle: String {
  /// Warm purple fading to peach.
  case dawn
  /// Deep navy.
  case night
  /// Dark olive green.
  case olive
  /// Neutral charcoal.
  case stone

  /// The style with `id`, or `.dawn` if there is no match.
  init(id: String?) {
    self = id.flatMap(WallpaperStyle.init(rawValue:)) ?? .dawn
  }

  /// Gradient color at the top of the screen, as 0xRRGGBB.
  var topRGB: UInt32 {
    switch self {
    case .dawn: 0x3B2A4D
    case .night: 0x0B1426
    case .olive: 0x1F2A1C
    case .stone: 0x2B2B2B
    }
  }

  /// Gradient color at the bottom of the screen, as 0xRRGGBB.
  var bottomRGB: UInt32 {
    switch self {
    case .dawn: 0xC9826B
    case .night: 0x22365C
    case .olive: 0x5C6B3E
    case .stone: 0x575350
    }
  }

  /// Color of the verse text, as 0xRRGGBB.
  var textRGB: UInt32 {
    switch self {
    case .dawn, .stone: 0xFFFFFF
    case .night: 0xF2EEE4
    case .olive: 0xF4F1E6
    }
  }

  /// Top-to-bottom gradient for SwiftUI (the home screen widget).
  var gradient: LinearGradient {
    LinearGradient(
      colors: [Color(rgb: topRGB), Color(rgb: bottomRGB)],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}

extension UIColor {
  /// Creates an opaque color from a 0xRRGGBB value.
  convenience init(rgb: UInt32) {
    self.init(
      red: CGFloat((rgb >> 16) & 0xFF) / 255,
      green: CGFloat((rgb >> 8) & 0xFF) / 255,
      blue: CGFloat(rgb & 0xFF) / 255,
      alpha: 1
    )
  }
}

private extension Color {
  /// Creates an opaque SwiftUI color from a 0xRRGGBB value.
  init(rgb: UInt32) {
    self.init(
      red: Double((rgb >> 16) & 0xFF) / 255,
      green: Double((rgb >> 8) & 0xFF) / 255,
      blue: Double(rgb & 0xFF) / 255
    )
  }
}
