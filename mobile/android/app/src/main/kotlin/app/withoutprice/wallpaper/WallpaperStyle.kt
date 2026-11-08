package app.withoutprice.wallpaper

/**
 * A wallpaper background.
 *
 * The ids and colors are duplicated in `lib/wallpaper/wallpaper_style.dart` and
 * `ios/VerseWidgetSources/WidgetStyle.swift`. Keep all three in sync.
 */
enum class WallpaperStyle(val id: String, val topColor: Int, val bottomColor: Int, val textColor: Int) {
    DAWN("dawn", 0xFF3B2A4D.toInt(), 0xFFC9826B.toInt(), 0xFFFFFFFF.toInt()),
    NIGHT("night", 0xFF0B1426.toInt(), 0xFF22365C.toInt(), 0xFFF2EEE4.toInt()),
    OLIVE("olive", 0xFF1F2A1C.toInt(), 0xFF5C6B3E.toInt(), 0xFFF4F1E6.toInt()),
    STONE("stone", 0xFF2B2B2B.toInt(), 0xFF575350.toInt(), 0xFFFFFFFF.toInt());

    companion object {
        /** The style with [id], or [DAWN] if there is no match. */
        fun fromId(id: String?): WallpaperStyle = entries.firstOrNull { it.id == id } ?: DAWN
    }
}
