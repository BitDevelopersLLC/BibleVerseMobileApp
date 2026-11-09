package app.withoutprice.wallpaper

/**
 * Where the verse sits on the wallpaper, in four vertical areas of the screen.
 *
 * Phones put the clock, fingerprint icon, and shortcuts in different places, so the user picks
 * the area that is clear on their own lock screen. Fractions are of the screen height, with 0 at
 * the very top. The verse is centered inside the area and shrinks to fit. Top and Bottom stop
 * short of the screen edges because some lock screens (Pixel) magnify the wallpaper by ~12%.
 *
 * The ids and fractions match `lib/wallpaper/verse_position.dart` and
 * `ios/Shared/VersePosition.swift`. Keep all three in sync.
 */
enum class VersePosition(val id: String, val bandTop: Float, val bandBottom: Float) {
    /** The top quarter (0-25%). Starts below the status bar. */
    TOP("top", 0.08f, 0.25f),

    /** The second quarter (25-50%). */
    UPPER_MIDDLE("upperMiddle", 0.26f, 0.49f),

    /** The third quarter (50-75%). */
    LOWER_MIDDLE("lowerMiddle", 0.51f, 0.74f),

    /** The bottom quarter (75-100%). Ends above the gesture bar. */
    BOTTOM("bottom", 0.76f, 0.90f);

    companion object {
        /** The position used until the user chooses one. Matches `VersePosition.defaultPosition`. */
        val DEFAULT = BOTTOM

        /** The position with [id], or [DEFAULT] if there is no match. */
        fun fromId(id: String?): VersePosition = entries.firstOrNull { it.id == id } ?: DEFAULT
    }
}
