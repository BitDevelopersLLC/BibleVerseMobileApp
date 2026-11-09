import UIKit
import XCTest

@testable import Runner

/// Checks the Swift rotation rule and wallpaper drawing.
///
/// The fixed numbers match `test/verse_library_test.dart` (Dart) and `VerseCadenceTest.kt`
/// (Android), so all three platforms are held to the same values.
final class VerseRotationTests: XCTestCase {
  /// A Gregorian calendar in a fixed time zone, so the tests don't depend on the Mac's settings.
  private var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    return calendar
  }

  private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
  }

  func testDailySlotMatchesOtherPlatforms() {
    XCTAssertEqual(VerseCadence.daily.slot(containing: date(2026, 11, 8, 12), calendar: calendar), 20765)
  }

  func testHourlySlotMatchesOtherPlatforms() {
    XCTAssertEqual(VerseCadence.hourly.slot(containing: date(2026, 11, 8, 12), calendar: calendar), 498372)
  }

  func testDailySlotIgnoresTimeOfDay() {
    let early = VerseCadence.daily.slot(containing: date(2026, 11, 8, 0, 5), calendar: calendar)
    let late = VerseCadence.daily.slot(containing: date(2026, 11, 8, 23, 55), calendar: calendar)
    let next = VerseCadence.daily.slot(containing: date(2026, 11, 9, 0, 5), calendar: calendar)
    XCTAssertEqual(early, late)
    XCTAssertEqual(next, early + 1)
  }

  func testHourlySlotContinuesAcrossMidnight() {
    let lastHour = VerseCadence.hourly.slot(containing: date(2026, 11, 8, 23, 30), calendar: calendar)
    let firstHour = VerseCadence.hourly.slot(containing: date(2026, 11, 9, 0, 30), calendar: calendar)
    XCTAssertEqual(firstHour, lastHour + 1)
  }

  func testStartOfNextSlot() {
    let now = date(2026, 11, 8, 14, 25)
    XCTAssertEqual(VerseCadence.daily.startOfNextSlot(after: now, calendar: calendar), date(2026, 11, 9, 0))
    XCTAssertEqual(VerseCadence.hourly.startOfNextSlot(after: now, calendar: calendar), date(2026, 11, 8, 15))
  }

  func testIndexWrapsAroundTheList() {
    XCTAssertEqual(VerseStore.index(forSlot: 20765, count: 168), 20765 % 168)
    XCTAssertEqual(VerseStore.index(forSlot: -1, count: 168), 167)
  }

  func testUnknownIdsFallBackToDefaults() {
    XCTAssertEqual(VerseCadence(id: nil), .daily)
    XCTAssertEqual(VerseCadence(id: "weekly"), .daily)
    XCTAssertEqual(VersePosition(id: "middle"), .bottom)
    XCTAssertEqual(WallpaperStyle(id: nil), .dawn)
  }

  func testRendererProducesAnImageOfTheRequestedSize() throws {
    let verse = CurrentVerse(
      id: "PSA_42_11",
      reference: "Psalm 42:11",
      text: "Why art thou cast down, O my soul? and why art thou disquieted within me? hope thou "
        + "in God: for I shall yet praise him, who is the health of my countenance, and my God.",
      translationId: "KJV",
      style: .dawn,
      position: .bottom
    )
    let png = try XCTUnwrap(WallpaperRenderer.pngData(for: verse, pixelSize: CGSize(width: 1320, height: 2868)))
    let image = try XCTUnwrap(UIImage(data: png))
    XCTAssertEqual(image.size.width * image.scale, 1320)
    XCTAssertEqual(image.size.height * image.scale, 2868)
  }
}
