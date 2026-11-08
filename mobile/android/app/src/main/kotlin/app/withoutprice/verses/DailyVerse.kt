package app.withoutprice.verses

import android.content.Context
import org.json.JSONObject
import java.util.Calendar
import java.util.TimeZone

/** A verse ready to display: its reference, its text, and the translation the text is in. */
data class Verse(val reference: String, val text: String, val translationId: String)

/** Reads the verse data that ships inside the app. Nothing is downloaded. */
object BundledVerses {
    /** Flutter packages `assets/verses.json` under this path in the APK. */
    private const val ASSET_PATH = "flutter_assets/assets/verses.json"

    /** Parses the bundled data file. */
    fun load(context: Context): JSONObject =
        context.assets.open(ASSET_PATH).bufferedReader().use { JSONObject(it.readText()) }
}

/**
 * Chooses the verse for a given day.
 *
 * The rule is shared by every platform: index = (days since 1970-01-01 for the local
 * calendar date) mod (number of verses). Dart (`verse_library.dart`) and Swift
 * (`VerseStore.swift`) implement the same calculation. Change all three together.
 */
object DailyVerse {
    private const val MILLIS_PER_DAY = 86_400_000L
    private const val FALLBACK_TRANSLATION = "BSB"

    /** Days since 1970-01-01 for today's date in the device's time zone. */
    fun localEpochDay(): Long {
        val local = Calendar.getInstance()
        val utcMidnight = Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
            clear()
            set(local.get(Calendar.YEAR), local.get(Calendar.MONTH), local.get(Calendar.DAY_OF_MONTH))
        }
        return Math.floorDiv(utcMidnight.timeInMillis, MILLIS_PER_DAY)
    }

    /** The verse for [epochDay] in [translationId], falling back to BSB if that translation is missing. */
    fun pick(data: JSONObject, epochDay: Long, translationId: String): Verse {
        val verses = data.getJSONArray("verses")
        val entry = verses.getJSONObject(Math.floorMod(epochDay, verses.length().toLong()).toInt())
        val texts = entry.getJSONObject("text")
        val translation = if (texts.has(translationId)) translationId else FALLBACK_TRANSLATION
        return Verse(entry.getString("ref"), texts.getString(translation), translation)
    }
}
