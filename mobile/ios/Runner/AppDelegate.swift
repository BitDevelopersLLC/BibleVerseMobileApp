import Flutter
import UIKit
import WidgetKit

/// Application delegate for the iOS app.
///
/// Besides the standard Flutter setup, it hosts the native side of the
/// `app.withoutprice/lockscreen` method channel (Dart: `lib/platform/lock_screen_channel.dart`).
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let channelName = "app.withoutprice/lockscreen"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerLockScreenChannel(with: engineBridge.pluginRegistry)
  }

  /// Handles `configure` by copying the user's choices into the App Group, where the widget
  /// and the "Get Today's Wallpaper" Shortcuts action read them (see `SharedSettings`).
  /// The other channel methods are Android-only and report "not implemented" here.
  private func registerLockScreenChannel(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "LockScreenChannel") else { return }
    let channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: registrar.messenger())

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "configure":
        let arguments = call.arguments as? [String: Any] ?? [:]
        // Only these choices are shared, and only with this app's own widget and Shortcuts action.
        let shared = SharedSettings.defaults
        let keys = [
          SharedSettings.Key.translation,
          SharedSettings.Key.style,
          SharedSettings.Key.position,
          SharedSettings.Key.cadence,
        ]
        for key in keys {
          // A missing value clears the key, so the readers fall back to their defaults.
          shared?.set(arguments[key] as? String, forKey: key)
        }
        // WidgetKit needs iOS 14; the widget itself requires iOS 17, so older systems skip this.
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
