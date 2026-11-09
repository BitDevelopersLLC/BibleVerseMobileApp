package app.withoutprice.wallpaper

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.graphics.Typeface
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import app.withoutprice.verses.Verse

/**
 * Draws a full-screen verse wallpaper.
 *
 * The layout matches `lib/wallpaper/wallpaper_renderer.dart`, which draws the in-app preview,
 * so what the user previews is what appears on the lock screen. Keep the constants in sync.
 */
object WallpaperRenderer {
    /** Horizontal margin on each side, as a fraction of the width. */
    private const val MARGIN_FRACTION = 0.10f

    /**
     * Top of the text band, below the lock screen clock. With no notifications, Android 15
     * shows a large clock centered on the screen that reaches about 66% of the height.
     */
    private const val BAND_TOP_FRACTION = 0.67f

    /** Height of the text band. The unlock icon and shortcut buttons sit below it (from ~85%). */
    private const val BAND_HEIGHT_FRACTION = 0.16f

    /** Starting verse font size, as a fraction of the width. */
    private const val START_FONT_FRACTION = 0.062f

    /** Smallest verse font size before the text is allowed to overflow. */
    private const val MIN_FONT_FRACTION = 0.035f

    /** Factor applied to the font size on each attempt to fit a long verse. */
    private const val SHRINK_STEP = 0.92f

    /** Reference font size relative to the verse font size. */
    private const val REFERENCE_SCALE = 0.62f

    /** Gap between the verse and the reference, relative to the verse font size. */
    private const val GAP_SCALE = 1.2f

    /** Line height multiplier for all text. */
    private const val LINE_HEIGHT = 1.25f

    /** Opacity of the reference line (0-255). */
    private const val REFERENCE_ALPHA = 210

    private const val SHADOW_COLOR = 0x66000000

    /** Returns a new [width] x [height] bitmap of [verse] on [style]. The caller recycles it. */
    fun render(width: Int, height: Int, verse: Verse, style: WallpaperStyle): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawPaint(Paint().apply {
            shader = LinearGradient(0f, 0f, 0f, height.toFloat(), style.topColor, style.bottomColor, Shader.TileMode.CLAMP)
        })

        val margin = width * MARGIN_FRACTION
        val textWidth = (width - 2 * margin).toInt()
        val bandTop = height * BAND_TOP_FRACTION
        val bandHeight = height * BAND_HEIGHT_FRACTION
        val reference = "${verse.reference} (${verse.translationId})"
        val serif = Typeface.create(Typeface.SERIF, Typeface.NORMAL)
        val boldSans = Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD)

        // Shrink long verses until they fit inside the band.
        var fontSize = width * START_FONT_FRACTION
        var body: StaticLayout
        var ref: StaticLayout
        while (true) {
            body = layout(verse.text, fontSize, style.textColor, 255, textWidth, serif)
            ref = layout(reference, fontSize * REFERENCE_SCALE, style.textColor, REFERENCE_ALPHA, textWidth, boldSans)
            val fits = body.height + fontSize * GAP_SCALE + ref.height <= bandHeight
            if (fits || fontSize < width * MIN_FONT_FRACTION) break
            fontSize *= SHRINK_STEP
        }

        val blockHeight = body.height + fontSize * GAP_SCALE + ref.height
        canvas.save()
        canvas.translate(margin, bandTop + (bandHeight - blockHeight) / 2f)
        body.draw(canvas)
        canvas.translate(0f, body.height + fontSize * GAP_SCALE)
        ref.draw(canvas)
        canvas.restore()
        return bitmap
    }

    private fun layout(text: String, fontSize: Float, color: Int, alpha: Int, width: Int, typeface: Typeface): StaticLayout {
        val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            textSize = fontSize
            this.color = color
            this.alpha = alpha
            this.typeface = typeface
            setShadowLayer(fontSize * 0.15f, 0f, fontSize * 0.05f, SHADOW_COLOR)
        }
        return StaticLayout.Builder.obtain(text, 0, text.length, paint, width)
            .setAlignment(Layout.Alignment.ALIGN_CENTER)
            .setLineSpacing(0f, LINE_HEIGHT)
            .build()
    }
}
