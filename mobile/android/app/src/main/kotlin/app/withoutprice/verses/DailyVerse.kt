package app.withoutprice.verses

import android.content.Context
import org.json.JSONObject

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
 * Chooses the verse for a rotation slot (see [VerseCadence.slotContaining]).
 *
 * The rule is shared by every platform: index = slot mod (number of verses). Dart
 * (`verse_library.dart`) and Swift (`VerseStore.swift`) implement the same calculation.
 * Change all three together.
 */
object DailyVerse {
    private const val FALLBACK_TRANSLATION = "BSB"

    /** The verse for [slot] in [translationId], falling back to BSB if that translation is missing. */
    fun pick(data: JSONObject, slot: Long, translationId: String): Verse {
        val verses = data.getJSONArray("verses")
        val entry = verses.getJSONObject(Math.floorMod(slot, verses.length().toLong()).toInt())
        val texts = entry.getJSONObject("text")
        val translation = if (texts.has(translationId)) translationId else FALLBACK_TRANSLATION
        return Verse(entry.getString("ref"), texts.getString(translation), translation)
    }
}
