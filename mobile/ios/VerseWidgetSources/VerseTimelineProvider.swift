import WidgetKit

/// One day's verse, as shown by the widget.
struct VerseEntry: TimelineEntry {
  /// When WidgetKit should start showing this entry.
  let date: Date
  /// Human-readable reference, for example "John 3:16".
  let reference: String
  /// The verse text in the chosen translation.
  let text: String
  /// Short translation code, for example "BSB".
  let translationId: String
  /// Background style id. See `WidgetStyle`.
  let styleId: String

  /// Shown in the widget gallery and while data is loading.
  static let placeholder = VerseEntry(
    date: .now,
    reference: "Psalm 119:105",
    text: "Your word is a lamp to my feet and a light to my path.",
    translationId: "BSB",
    styleId: WidgetStyle.dawn.rawValue
  )
}

/// Supplies a week of entries at a time, one per local midnight.
struct VerseTimelineProvider: TimelineProvider {
  /// How many days ahead each timeline covers. WidgetKit asks for a new one when it runs out.
  private static let daysPerTimeline = 7

  func placeholder(in context: Context) -> VerseEntry {
    .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
    completion(VerseStore.entry(for: .now) ?? .placeholder)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)

    var entries = [VerseStore.entry(for: .now)].compactMap { $0 }
    for offset in 1...Self.daysPerTimeline {
      if let midnight = calendar.date(byAdding: .day, value: offset, to: today),
         let entry = VerseStore.entry(for: midnight) {
        entries.append(entry)
      }
    }
    if entries.isEmpty {
      entries = [.placeholder]
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }
}
