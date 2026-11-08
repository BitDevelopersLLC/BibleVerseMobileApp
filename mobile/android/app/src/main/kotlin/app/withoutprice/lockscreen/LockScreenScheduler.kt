package app.withoutprice.lockscreen

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import java.util.concurrent.TimeUnit

/** Saves the user's lock screen choices and schedules the background job that applies them. */
object LockScreenScheduler {

    /**
     * How often the job wakes up. Each run returns immediately unless the date has changed,
     * so the new verse appears within this long after midnight at almost no battery cost.
     */
    private const val CHECK_INTERVAL_HOURS = 1L

    private const val PERIODIC_WORK_NAME = "daily-verse-wallpaper"
    private const val IMMEDIATE_WORK_NAME = "verse-wallpaper-now"

    /** Stores [choices] and starts (or cancels) the daily job to match them. */
    fun configure(context: Context, choices: LockScreenPreferences.Choices) {
        val preferences = LockScreenPreferences(context)
        val previous = preferences.choices
        preferences.choices = choices

        val workManager = WorkManager.getInstance(context)
        if (!choices.enabled) {
            workManager.cancelUniqueWork(PERIODIC_WORK_NAME)
            return
        }

        // The first periodic run is delayed: WorkManager would otherwise start it immediately,
        // at the same moment as applyNow() below, and two simultaneous setBitmap() calls can
        // leave the system's lock wallpaper in an inconsistent state.
        val periodic = PeriodicWorkRequestBuilder<VerseWallpaperWorker>(CHECK_INTERVAL_HOURS, TimeUnit.HOURS)
            .setInitialDelay(CHECK_INTERVAL_HOURS, TimeUnit.HOURS)
            .build()
        // KEEP leaves an existing schedule alone, so opening the app doesn't reset the timer.
        workManager.enqueueUniquePeriodicWork(PERIODIC_WORK_NAME, ExistingPeriodicWorkPolicy.KEEP, periodic)

        // Redraw right away when the feature is first turned on or the look changes.
        if (choices != previous) applyNow(context)
    }

    /** Draws and sets today's verse as soon as possible, even if it was already set today. */
    fun applyNow(context: Context) {
        val request = OneTimeWorkRequestBuilder<VerseWallpaperWorker>()
            .setInputData(workDataOf(VerseWallpaperWorker.KEY_FORCE to true))
            .build()
        WorkManager.getInstance(context).enqueueUniqueWork(IMMEDIATE_WORK_NAME, ExistingWorkPolicy.REPLACE, request)
    }
}
