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
    )

    private val prefs = context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    /** The saved choices, or the defaults if nothing has been saved yet. */
    var choices: Choices
        get() = Choices(
            enabled = prefs.getBoolean(KEY_ENABLED, false),
            translationId = prefs.getString(KEY_TRANSLATION, null) ?: DEFAULT_TRANSLATION,
            styleId = prefs.getString(KEY_STYLE, null) ?: DEFAULT_STYLE,
            positionId = prefs.getString(KEY_POSITION, null) ?: DEFAULT_POSITION,
        )
        set(value) = edit {
            putBoolean(KEY_ENABLED, value.enabled)
            putString(KEY_TRANSLATION, value.translationId)
            putString(KEY_STYLE, value.styleId)
            putString(KEY_POSITION, value.positionId)
        }

    /** The epoch day whose verse is currently on the lock screen, or `null` if none has been set. */
    var lastAppliedDay: Long?
        get() = if (prefs.contains(KEY_LAST_APPLIED_DAY)) prefs.getLong(KEY_LAST_APPLIED_DAY, 0) else null
        set(value) = edit {
            if (value == null) remove(KEY_LAST_APPLIED_DAY) else putLong(KEY_LAST_APPLIED_DAY, value)
        }

    private inline fun edit(block: SharedPreferences.Editor.() -> Unit) = prefs.edit().apply(block).apply()

    companion object {
        /** Translation used until the user picks one. Matches `VerseLibrary.defaultTranslationId`. */
        const val DEFAULT_TRANSLATION = "BSB"

        /** Style used until the user picks one. Matches `WallpaperStyle.dawn`. */
        const val DEFAULT_STYLE = "dawn"

        /** Position used until the user picks one. Matches `VersePosition.DEFAULT`. */
        const val DEFAULT_POSITION = "bottom"

        private const val FILE_NAME = "lockscreen"
        private const val KEY_ENABLED = "enabled"
        private const val KEY_TRANSLATION = "translation"
        private const val KEY_STYLE = "style"
        private const val KEY_POSITION = "position"
        private const val KEY_LAST_APPLIED_DAY = "lastAppliedDay"
    }
}
