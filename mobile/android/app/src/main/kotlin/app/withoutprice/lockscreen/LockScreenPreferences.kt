package app.withoutprice.lockscreen

import android.content.Context
import android.content.SharedPreferences

/**
 * The lock screen choices the background job needs, stored in private app storage.
 *
 * The Flutter UI keeps its own copy of these settings. This copy exists so the
 * background job can run without starting Flutter.
 */
class LockScreenPreferences(context: Context) {

    /** What the user picked in the app. */
    data class Choices(
        val enabled: Boolean,
        val translationId: String,
        val styleId: String,
        val positionId: String,
        val cadenceId: String,
    )

    private val prefs = context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    /** The saved choices, or the defaults if nothing has been saved yet. */
    var choices: Choices
        get() = Choices(
            enabled = prefs.getBoolean(KEY_ENABLED, false),
            translationId = prefs.getString(KEY_TRANSLATION, null) ?: DEFAULT_TRANSLATION,
            styleId = prefs.getString(KEY_STYLE, null) ?: DEFAULT_STYLE,
            positionId = prefs.getString(KEY_POSITION, null) ?: DEFAULT_POSITION,
            cadenceId = prefs.getString(KEY_CADENCE, null) ?: DEFAULT_CADENCE,
        )
        set(value) = edit {
            putBoolean(KEY_ENABLED, value.enabled)
            putString(KEY_TRANSLATION, value.translationId)
            putString(KEY_STYLE, value.styleId)
            putString(KEY_POSITION, value.positionId)
            putString(KEY_CADENCE, value.cadenceId)
        }

    /**
     * The rotation slot whose verse is currently on the lock screen, or `null` if none has been set.
     * See [app.withoutprice.verses.VerseCadence.slotContaining].
     */
    var lastAppliedSlot: Long?
        get() = if (prefs.contains(KEY_LAST_APPLIED_SLOT)) prefs.getLong(KEY_LAST_APPLIED_SLOT, 0) else null
        set(value) = edit {
            if (value == null) remove(KEY_LAST_APPLIED_SLOT) else putLong(KEY_LAST_APPLIED_SLOT, value)
            // Written by version 1.0.0, which only had daily slots. After updating, the first run
            // redraws the same verse once and the old key is no longer needed.
            remove(LEGACY_KEY_LAST_APPLIED_DAY)
        }

    private inline fun edit(block: SharedPreferences.Editor.() -> Unit) = prefs.edit().apply(block).apply()

    companion object {
        /** Translation used until the user picks one. Matches `VerseLibrary.defaultTranslationId`. */
        const val DEFAULT_TRANSLATION = "BSB"

        /** Style used until the user picks one. Matches `WallpaperStyle.dawn`. */
        const val DEFAULT_STYLE = "dawn"

        /** Position used until the user picks one. Matches `VersePosition.DEFAULT`. */
        const val DEFAULT_POSITION = "bottom"

        /** Cadence used until the user picks one. Matches `VerseCadence.defaultCadence`. */
        const val DEFAULT_CADENCE = "daily"

        private const val FILE_NAME = "lockscreen"
        private const val KEY_ENABLED = "enabled"
        private const val KEY_TRANSLATION = "translation"
        private const val KEY_STYLE = "style"
        private const val KEY_POSITION = "position"
        private const val KEY_CADENCE = "cadence"
        private const val KEY_LAST_APPLIED_SLOT = "lastAppliedSlot"
        private const val LEGACY_KEY_LAST_APPLIED_DAY = "lastAppliedDay"
    }
}
