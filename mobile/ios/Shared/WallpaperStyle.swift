import SwiftUI

/// Background for the home screen and StandBy widget.
///
/// The ids and colors match `lib/wallpaper/wallpaper_style.dart` and `WallpaperStyle.kt`.
/// Keep all three in sync.
enum WidgetStyle: String {
  case dawn, night, olive, stone

  /// The style with `id`, or `.dawn` if there is no match.
  init(id: String) {
    self = WidgetStyle(rawValue: id) ?? .dawn
  }

  /// Top-to-bottom gradient for this style.
  var gradient: LinearGradient {
    let (top, bottom): (UInt32, UInt32) = switch self {
    case .dawn: (0x3B2A4D, 0xC9826B)
    case .night: (0x0B1426, 0x22365C)
    case .olive: (0x1F2A1C, 0x5C6B3E)
    case .stone: (0x2B2B2B, 0x575350)
    }
    return LinearGradient(colors: [Color(rgb: top), Color(rgb: bottom)], startPoint: .top, endPoint: .bottom)
  }
}

private extension Color {
  /// Creates an opaque color from a 0xRRGGBB value.
  init(rgb: UInt32) {
    self.init(
      red: Double((rgb >> 16) & 0xFF) / 255,
      green: Double((rgb >> 8) & 0xFF) / 255,
      blue: Double(rgb & 0xFF) / 255
    )
  }
}
