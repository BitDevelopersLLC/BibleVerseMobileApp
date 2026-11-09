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

  /// The main lock screen widget: up to three lines of verse plus the reference.
  /// The system tints lock screen widgets to match the wallpaper, so no colors are set here.
  private var rectangular: some View {
    VStack(alignment: .leading, spacing: 1) {
      Text(entry.text)
        .font(.system(.caption, design: .serif))
        .lineLimit(3)
        .minimumScaleFactor(0.7)
      Text(entry.reference)
        .font(.system(size: 10, weight: .semibold))
        .lineLimit(1)
        .widgetAccentable()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .containerBackground(.clear, for: .widget)
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
