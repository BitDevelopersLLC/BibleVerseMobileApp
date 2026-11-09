package app.withoutprice.lockscreen

import android.app.WallpaperManager
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native side of the `app.withoutprice/lockscreen` method channel.
 *
 * The Dart side is `lib/platform/lock_screen_channel.dart`. Methods:
 * - `isSupported` returns whether this device lets apps change the lock screen wallpaper.
 * - `configure` takes `{enabled, translation, style, position}`, saves them, and starts or stops the daily job.
 * - `applyNow` draws and sets today's verse immediately.
 */
class LockScreenChannel private constructor(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSupported" -> result.success(isSupported())
            "configure" -> {
                LockScreenScheduler.configure(
                    context,
                    LockScreenPreferences.Choices(
                        enabled = call.argument<Boolean>("enabled") ?: false,
                        translationId = call.argument<String>("translation") ?: LockScreenPreferences.DEFAULT_TRANSLATION,
                        styleId = call.argument<String>("style") ?: LockScreenPreferences.DEFAULT_STYLE,
                        positionId = call.argument<String>("position") ?: LockScreenPreferences.DEFAULT_POSITION,
                    ),
                )
                result.success(null)
            }
            "applyNow" -> {
                LockScreenScheduler.applyNow(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun isSupported(): Boolean {
        val wallpaperManager = WallpaperManager.getInstance(context)
        return wallpaperManager.isWallpaperSupported && wallpaperManager.isSetWallpaperAllowed
    }

    companion object {
        private const val CHANNEL_NAME = "app.withoutprice/lockscreen"

        /** Connects the channel to the Flutter engine that owns [messenger]. */
        fun register(messenger: BinaryMessenger, context: Context) {
            MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler(LockScreenChannel(context))
        }
    }
}
