import Foundation

/// How often a new verse appears: once a day (the default) or once an hour.
///
/// The ids and the rotation rule are duplicated in `lib/data/verse_cadence.dart` (Dart) and
/// `VerseCadence.kt` (Android). Change all three together.
enum VerseCadence: String {
  /// A new verse at local midnight.
  case daily
  /// A new verse at the start of every local hour.
  case hourly

  private static let hoursPerDay = 24

  /// The cadence with `id`, or `.daily` if there is no match.
  init(id: String?) {
    self = id.flatMap(VerseCadence.init(rawValue:)) ?? .daily
  }

  /// The rotation slot that contains `date`: which verse to show is `slot mod verseCount`.
  ///
  /// * Daily: days since 1970-01-01 for the local calendar date.
  /// * Hourly: that day number times 24, plus the local hour (0-23).
  ///
  /// Daily slots are unchanged from the original once-a-day rule, so switching an existing
  /// install to this code doesn't change its verse.
  func slot(containing date: Date, calendar: Calendar = .gregorianLocal) -> Int {
    let day = Self.localEpochDay(for: date, calendar: calendar)
    switch self {
    case .daily:
      return day
    case .hourly:
      return day * Self.hoursPerDay + calendar.component(.hour, from: date)
    }
  }

  /// The first moment of the slot after the one that contains `date` (the next local midnight
  /// or the next full hour).
  func startOfNextSlot(after date: Date, calendar: Calendar = .gregorianLocal) -> Date {
    switch self {
    case .daily:
      let today = calendar.startOfDay(for: date)
      return calendar.date(byAdding: .day, value: 1, to: today) ?? date.addingTimeInterval(86_400)
    case .hourly:
      let hour = calendar.dateInterval(of: .hour, for: date)?.start ?? date
      return calendar.date(byAdding: .hour, value: 1, to: hour) ?? date.addingTimeInterval(3_600)
    }
  }

  /// Days since 1970-01-01 for the calendar date of `date` in `calendar`'s time zone.
  ///
  /// Uses the date's year, month and day only, so the time of day and daylight saving time
  /// never affect the result.
  static func localEpochDay(for date: Date, calendar: Calendar = .gregorianLocal) -> Int {
    let day = calendar.dateComponents([.year, .month, .day], from: date)
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = TimeZone(identifier: "UTC") ?? TimeZone(secondsFromGMT: 0) ?? .current
    guard let midnightUTC = utc.date(from: day) else { return 0 }
    return Int((midnightUTC.timeIntervalSince1970 / 86_400).rounded(.down))
  }
}

extension Calendar {
  /// A Gregorian calendar in the device's current time zone.
  ///
  /// The rotation always uses the Gregorian calendar, so the verse doesn't depend on the
  /// user's calendar setting (Buddhist, Japanese, and so on).
  static var gregorianLocal: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current
    return calendar
  }
}
