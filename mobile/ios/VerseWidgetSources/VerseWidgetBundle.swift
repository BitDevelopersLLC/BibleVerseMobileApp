import SwiftUI
import WidgetKit

/// Entry point of the VerseWidget extension.
@main
struct VerseWidgetBundle: WidgetBundle {
  var body: some Widget {
    VerseWidget()
  }
}

/// Today's verse on the lock screen (rectangular and inline), the home screen, and StandBy.
struct VerseWidget: Widget {
  /// Identifier used by WidgetKit to reload this widget's timelines.
  static let kind = "VerseWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: Self.kind, provider: VerseTimelineProvider()) { entry in
      VerseWidgetView(entry: entry)
    }
    .configurationDisplayName("Verse")
    .description("Today's verse. Changes every day.")
    .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
  }
}
