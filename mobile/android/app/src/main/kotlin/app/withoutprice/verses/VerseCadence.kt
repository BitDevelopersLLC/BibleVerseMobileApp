package app.withoutprice.verses

import java.util.Calendar
import java.util.TimeZone

/**
 * How often a new verse appears: once a day (the default) or once an hour.
 *
 * The ids and the rotation rule are duplicated in `lib/data/verse_cadence.dart` (Dart) and
 * `ios/Shared/VerseCadence.swift` (iOS). Change all three together.
 */
enum class VerseCadence(val id: String, val checkIntervalMinutes: Long) {
    /** A new verse at local midnight. The background job checks once an hour. */
    DAILY("daily", 60),

    /**
     * A new verse at the start of every local hour. The background job checks every 15 minutes,
     * the shortest interval WorkManager allows, so the new verse appears soon after the hour.
     */
    HOURLY("hourly", 15);

    /**
     * The rotation slot that contains [now]: which verse to show is `slot mod verseCount`.
     *
     * - Daily: days since 1970-01-01 for the local calendar date.
     * - Hourly: that day number times 24, plus the local hour (0-23).
     *
     * Daily slots are the same numbers as the original once-a-day rule, so existing installs
     * keep their verse after updating.
     */
    fun slotContaining(now: Calendar = Calendar.getInstance()): Long {
        val day = localEpochDay(now)
        return when (this) {
            DAILY -> day
            HOURLY -> day * HOURS_PER_DAY + now.get(Calendar.HOUR_OF_DAY)
        }
    }

    companion object {
        /** The cadence used until the user chooses one. Matches `VerseCadence.defaultCadence`. */
        val DEFAULT = DAILY

        private const val HOURS_PER_DAY = 24L
        private const val MILLIS_PER_DAY = 86_400_000L

        /** The cadence with [id], or [DEFAULT] if there is no match. */
        fun fromId(id: String?): VerseCadence = entries.firstOrNull { it.id == id } ?: DEFAULT

        /**
         * Days since 1970-01-01 for the calendar date of [now] in its time zone.
         *
         * Uses the year, month and day only, so the time of day and daylight saving time never
         * affect the result.
         */
        fun localEpochDay(now: Calendar = Calendar.getInstance()): Long {
            val utcMidnight = Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
                clear()
                set(now.get(Calendar.YEAR), now.get(Calendar.MONTH), now.get(Calendar.DAY_OF_MONTH))
            }
            return Math.floorDiv(utcMidnight.timeInMillis, MILLIS_PER_DAY)
        }
    }
}
