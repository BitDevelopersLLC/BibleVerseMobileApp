import WidgetKit

/// One verse, as shown by the widget from `date` until the next entry.
struct VerseEntry: TimelineEntry {
  /// When WidgetKit should start showing this entry.
  let date: Date
  /// Human-readable reference, for example "John 3:16".
  let reference: String
  /// The verse text in the chosen translation.
  let text: String
  /// Short translation code, for example "BSB".
  let translationId: String
  /// Background for the home screen and StandBy widget.
  let style: WallpaperStyle

  /// Shown in the widget gallery and while data is loading.
  static let placeholder = VerseEntry(
    date: .now,
    reference: "Psalm 119:105",
    text: "Your word is a lamp to my feet and a light to my path.",
    translationId: "BSB",
    style: .dawn
  )

  /// The entry for the moment `date`, or `nil` if the bundled verse data can't be read.
  static func at(_ date: Date) -> VerseEntry? {
    VerseStore.verse(at: date).map { verse in
      VerseEntry(
        date: date,
        reference: verse.reference,
        text: verse.text,
        translationId: verse.translationId,
        style: verse.style
      )
    }
  }
}

/// Supplies the widget's verses ahead of time, one entry per rotation slot.
///
/// With the daily cadence a timeline covers the next week (one entry per local midnight); with
/// the hourly cadence it covers the next day (one entry per hour). WidgetKit switches entries
/// on time by itself and asks for a new timeline when this one runs out. The app also reloads
/// the timeline whenever the user changes a setting (`AppDelegate`).
struct VerseTimelineProvider: TimelineProvider {
  /// How many upcoming slots each timeline includes, after the current one.
  private static func upcomingSlotCount(for cadence: VerseCadence) -> Int {
    switch cadence {
    case .daily: 7
    case .hourly: 24
    }
  }

  func placeholder(in context: Context) -> VerseEntry {
    .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
    completion(VerseEntry.at(.now) ?? .placeholder)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
    let cadence = SharedSettings.cadence

    var entries = [VerseEntry.at(.now)].compactMap { $0 }
    var slotStart = Date.now
    for _ in 0..<Self.upcomingSlotCount(for: cadence) {
      slotStart = cadence.startOfNextSlot(after: slotStart)
      if let entry = VerseEntry.at(slotStart) {
        entries.append(entry)
      }
    }
    if entries.isEmpty {
      entries = [.placeholder]
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }
}
