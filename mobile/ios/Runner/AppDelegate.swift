import Flutter
import UIKit
import WidgetKit

/// Application delegate for the iOS app.
///
/// Besides the standard Flutter setup, it hosts the native side of the
/// `app.withoutprice/lockscreen` method channel (Dart: `lib/platform/lock_screen_channel.dart`).
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Shared with the VerseWidget extension so the widget follows the user's choices.
  /// Must match `VerseStore.appGroup` and both targets' App Group capability.
  static let appGroup = "group.app.withoutprice"

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

  /// Handles `configure` by sharing the translation and style with the widget.
  /// The other channel methods are Android-only and report "not implemented" here.
  private func registerLockScreenChannel(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "LockScreenChannel") else { return }
    let channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: registrar.messenger())

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "configure":
        let arguments = call.arguments as? [String: Any] ?? [:]
        // Only these two choices are shared, and only with this app's own widget.
        let shared = UserDefaults(suiteName: Self.appGroup)
        shared?.set(arguments["translation"] as? String ?? "BSB", forKey: "translation")
        shared?.set(arguments["style"] as? String ?? "dawn", forKey: "style")
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
