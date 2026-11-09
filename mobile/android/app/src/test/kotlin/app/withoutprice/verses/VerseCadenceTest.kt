package app.withoutprice.verses

import org.junit.Assert.assertEquals
import org.junit.Test
import java.util.Calendar
import java.util.TimeZone

/**
 * Checks the Android rotation rule.
 *
 * The fixed numbers match `test/verse_library_test.dart` (Dart) and `VerseRotationTests.swift`
 * (iOS), so all three platforms are held to the same values.
 */
class VerseCadenceTest {

    /** A calendar at the given local time in a fixed time zone. */
    private fun at(year: Int, month: Int, day: Int, hour: Int, minute: Int = 0): Calendar =
        Calendar.getInstance(TimeZone.getTimeZone("America/Los_Angeles")).apply {
            clear()
            set(year, month - 1, day, hour, minute)
        }

    @Test
    fun dailySlotMatchesOtherPlatforms() {
        assertEquals(20765L, VerseCadence.DAILY.slotContaining(at(2026, 11, 8, 12)))
    }

    @Test
    fun hourlySlotMatchesOtherPlatforms() {
        assertEquals(498372L, VerseCadence.HOURLY.slotContaining(at(2026, 11, 8, 12)))
    }

    @Test
    fun dailySlotIgnoresTimeOfDay() {
        val early = VerseCadence.DAILY.slotContaining(at(2026, 11, 8, 0, 5))
        val late = VerseCadence.DAILY.slotContaining(at(2026, 11, 8, 23, 55))
        val next = VerseCadence.DAILY.slotContaining(at(2026, 11, 9, 0, 5))
        assertEquals(early, late)
        assertEquals(early + 1, next)
    }

    @Test
    fun hourlySlotContinuesAcrossMidnight() {
        val lastHour = VerseCadence.HOURLY.slotContaining(at(2026, 11, 8, 23, 30))
        val firstHour = VerseCadence.HOURLY.slotContaining(at(2026, 11, 9, 0, 30))
        assertEquals(lastHour + 1, firstHour)
    }

    @Test
    fun unknownIdFallsBackToDaily() {
        assertEquals(VerseCadence.DAILY, VerseCadence.fromId(null))
        assertEquals(VerseCadence.DAILY, VerseCadence.fromId("weekly"))
        assertEquals(VerseCadence.HOURLY, VerseCadence.fromId("hourly"))
    }

    @Test
    fun hourlyChecksMoreOftenThanDaily() {
        assertEquals(60L, VerseCadence.DAILY.checkIntervalMinutes)
        assertEquals(15L, VerseCadence.HOURLY.checkIntervalMinutes)
    }
}
