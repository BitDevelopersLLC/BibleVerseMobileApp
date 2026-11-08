package app.withoutprice

import app.withoutprice.lockscreen.LockScreenChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/** The single Android activity. It hosts the Flutter UI and connects the native lock screen code. */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        LockScreenChannel.register(flutterEngine.dartExecutor.binaryMessenger, applicationContext)
    }
}
