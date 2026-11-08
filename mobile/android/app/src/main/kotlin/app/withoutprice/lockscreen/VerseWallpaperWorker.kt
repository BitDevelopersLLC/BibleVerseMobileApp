package app.withoutprice.lockscreen

import android.app.WallpaperManager
import android.content.Context
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.util.Size
import android.view.WindowManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import app.withoutprice.verses.BundledVerses
import app.withoutprice.verses.DailyVerse
import app.withoutprice.wallpaper.WallpaperRenderer
import app.withoutprice.wallpaper.WallpaperStyle

/**
 * Background job that puts today's verse on the lock screen.
 *
 * It runs without starting Flutter: it reads the bundled verse data, draws the wallpaper
 * natively, and sets it with [WallpaperManager.FLAG_LOCK] so the home screen is untouched.
 */
class VerseWallpaperWorker(context: Context, params: WorkerParameters) : Worker(context, params) {

    override fun doWork(): Result {
        val preferences = LockScreenPreferences(applicationContext)
        val choices = preferences.choices
        if (!choices.enabled) return Result.success()

        val today = DailyVerse.localEpochDay()
        val force = inputData.getBoolean(KEY_FORCE, false)
        if (!force && preferences.lastAppliedDay == today) return Result.success()

        return try {
            val verse = DailyVerse.pick(BundledVerses.load(applicationContext), today, choices.translationId)
            val size = portraitScreenSize()
            val bitmap = WallpaperRenderer.render(size.width, size.height, verse, WallpaperStyle.fromId(choices.styleId))
            try {
                WallpaperManager.getInstance(applicationContext)
                    .setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
            } finally {
                bitmap.recycle()
            }
            preferences.lastAppliedDay = today
            Result.success()
        } catch (e: Exception) {
            Log.w(TAG, "Could not set the lock screen verse (attempt ${runAttemptCount + 1})", e)
            if (runAttemptCount + 1 < MAX_ATTEMPTS) Result.retry() else Result.failure()
        }
    }

    /** Full physical screen size in pixels, always as portrait (width < height). */
    private fun portraitScreenSize(): Size {
        val windowManager = applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val (a, b) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = windowManager.maximumWindowMetrics.bounds
            bounds.width() to bounds.height()
        } else {
            val metrics = DisplayMetrics()
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getRealMetrics(metrics)
            metrics.widthPixels to metrics.heightPixels
        }
        return Size(minOf(a, b), maxOf(a, b))
    }

    companion object {
        /** Input flag: set the wallpaper even if today's verse is already on the lock screen. */
        const val KEY_FORCE = "force"

        private const val TAG = "WithoutPrice"

        /** Retries for transient failures. The hourly job tries again later regardless. */
        private const val MAX_ATTEMPTS = 3
    }
}
