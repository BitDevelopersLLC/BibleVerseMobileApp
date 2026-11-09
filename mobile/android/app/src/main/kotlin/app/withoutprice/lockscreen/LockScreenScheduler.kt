package app.withoutprice.lockscreen

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import app.withoutprice.verses.VerseCadence
import java.util.concurrent.TimeUnit

/** Saves the user's lock screen choices and schedules the background job that applies them. */
object LockScreenScheduler {

    private const val PERIODIC_WORK_NAME = "daily-verse-wallpaper"
    private const val IMMEDIATE_WORK_NAME = "verse-wallpaper-now"

    /**
     * Stores [choices] and starts (or cancels) the background job to match them.
     *
     * The job wakes up every [VerseCadence.checkIntervalMinutes] (an hour for the daily cadence,
     * 15 minutes for hourly). Each run returns immediately unless a new verse is due, so the
     * verse changes soon after midnight or the top of the hour at almost no battery cost.
     */
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
        val interval = VerseCadence.fromId(choices.cadenceId).checkIntervalMinutes
        val periodic = PeriodicWorkRequestBuilder<VerseWallpaperWorker>(interval, TimeUnit.MINUTES)
            .setInitialDelay(interval, TimeUnit.MINUTES)
            .build()
        // UPDATE applies a new interval when the cadence changes but keeps the existing schedule's
        // timing, so opening the app doesn't reset the timer.
        workManager.enqueueUniquePeriodicWork(PERIODIC_WORK_NAME, ExistingPeriodicWorkPolicy.UPDATE, periodic)

        // Redraw right away when the feature is first turned on or the look changes.
        if (choices != previous) applyNow(context)
    }

    /** Draws and sets the current verse as soon as possible, even if it is already on the lock screen. */
    fun applyNow(context: Context) {
        val request = OneTimeWorkRequestBuilder<VerseWallpaperWorker>()
            .setInputData(workDataOf(VerseWallpaperWorker.KEY_FORCE to true))
            .build()
        WorkManager.getInstance(context).enqueueUniqueWork(IMMEDIATE_WORK_NAME, ExistingWorkPolicy.REPLACE, request)
    }
}
