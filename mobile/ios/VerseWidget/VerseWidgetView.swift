import SwiftUI
import WidgetKit

/// Draws a `VerseEntry` for each supported widget family.
struct VerseWidgetView: View {
  @Environment(\.widgetFamily) private var family

  /// The verse to show.
  let entry: VerseEntry

  var body: some View {
    switch family {
    case .accessoryInline:
      inline
    case .accessoryRectangular:
      rectangular
    default:
      homeScreen
    }
  }

  /// One line above the clock: the verse if it fits, otherwise just the reference.
  private var inline: some View {
    ViewThatFits {
      Text(entry.text)
      Text(entry.reference)
    }
    .containerBackground(.clear, for: .widget)
  }

  /// Verse font sizes for the rectangular widget, largest first. The widget uses the largest size
  /// at which the whole verse fits, so short verses fill the box and long ones still show in full.
  private static let rectangularFontSizes: [CGFloat] = [22, 20, 18, 17, 16, 15, 14, 13, 12, 11]

  /// The main lock screen widget: the verse, centered and as large as fits, above the reference.
  /// The system tints lock screen widgets to match the wallpaper, so no colors are set here.
  private var rectangular: some View {
    VStack(spacing: 2) {
      ViewThatFits(in: .vertical) {
        ForEach(Self.rectangularFontSizes, id: \.self) { size in
          rectangularVerse(size: size)
            .fixedSize(horizontal: false, vertical: true)
        }
        // Fallback for a verse too long even at the smallest size: shrink a little more, then truncate.
        rectangularVerse(size: Self.rectangularFontSizes.last ?? 11)
          .minimumScaleFactor(0.85)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      Text(entry.reference)
        .font(.system(size: 11, weight: .semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .widgetAccentable()
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .containerBackground(.clear, for: .widget)
  }

  /// The verse text for the rectangular widget at a given font size.
  private func rectangularVerse(size: CGFloat) -> some View {
    Text(entry.text)
      .font(.system(size: size, weight: .medium, design: .serif))
      .lineSpacing(-1)
  }

  /// Home screen and StandBy: the verse on the user's chosen gradient.
  private var homeScreen: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(entry.text)
        .font(.system(family == .systemSmall ? .footnote : .body, design: .serif))
        .minimumScaleFactor(0.6)
      Spacer(minLength: 0)
      Text("\(entry.reference) (\(entry.translationId))")
        .font(.caption2.weight(.semibold))
        .opacity(0.85)
    }
    .foregroundStyle(.white)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .containerBackground(WidgetStyle(id: entry.styleId).gradient, for: .widget)
  }
}
