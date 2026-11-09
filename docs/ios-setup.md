# iOS setup (do this on the Mac)

## 0. Before starting

Already done from Windows (don't redo): the Apple Developer identifiers (App Group
`group.app.withoutprice`, App IDs `app.withoutprice` and `app.withoutprice.VerseWidget`, both
linked to the group) and the whole App Store Connect listing (text, privacy, age rating, pricing,
availability without China mainland, automatic release). See `docs/app-store-listing.md`.

On the Mac you need: Dropbox fully synced, Xcode, Flutter (`flutter doctor` clean for iOS),
CocoaPods, and Python 3 with Pillow (`python3 -m pip install pillow`) for the screenshot framing.

The Flutter app, the method channel in `AppDelegate.swift`, and the widget's Swift source are
already written. Adding a widget extension means editing the Xcode project, so those steps
have to happen in Xcode.

## 1. Open and run the plain app first

```bash
cd mobile
flutter pub get
cd ios && pod install && cd ..
flutter run            # on a real iPhone or a simulator
```

## 2. Signing and App Group (Runner target)

Already configured in the project (done 2026-11-08), so a fresh clone only needs a signed-in Xcode:

- Runner target > Signing & Capabilities: Team = Bit Developers LLC, bundle ID `app.withoutprice`,
  automatic signing.
- **App Groups** capability with `group.app.withoutprice` (`ios/Runner/Runner.entitlements`).
- `ios/Runner/PrivacyInfo.xcprivacy` is a member of the **Runner** target.

## 3. The widget extension

Also already in the project. For reference, this is how it is set up:

- Target **VerseWidgetExtension** (Widget Extension template, without Live Activity, Control or
  Configuration App Intent), bundle ID `app.withoutprice.VerseWidget`, same team, minimum iOS 17.0.
- `ios/VerseWidget/` is a folder Xcode keeps in sync with the target: every file in it is part of the
  widget automatically (only `Info.plist` is excluded from resources). It holds
  `VerseWidgetBundle.swift` (entry point), `VerseTimelineProvider.swift`, `VerseStore.swift`,
  `VerseWidgetView.swift`, `WidgetStyle.swift`, `PrivacyInfo.xcprivacy` and `Assets.xcassets`.
- `mobile/assets/verses.json` is added to the widget's Resources as a reference, not a copy, so it
  stays in sync with `tools/build_verses.py`.
- **App Groups** > `group.app.withoutprice` (`ios/VerseWidgetExtension.entitlements`).
- Runner target > Build Phases: **Embed Foundation Extensions** (VerseWidgetExtension.appex) runs
  *before* "Thin Binary". Flutter projects fail with a "cycle" error otherwise.

## 4. Test

- Run on a real iPhone. Lock it, touch and hold the lock screen, then Customize > Lock Screen > tap the widget box > Without Price.
- In the app, change the translation and check that the widget updates.
- Check the wallpaper feature: style > Save to Photos > set it through the lock screen editor.

## 5. Screenshots (required for submission)

| Device | Simulator | Size |
|---|---|---|
| iPhone 6.9" | iPhone Pro Max (newest) | 1320 x 2868 |
| iPad 13" | iPad Pro 13-inch (newest) | 2064 x 2752 |
| iPhone Duo (optional, earns the "made for iPhone Duo" badge) | iPhone Duo | check App Store Connect for the size |

1. Clean status bar: `xcrun simctl status_bar booted override --time 9:41 --batteryLevel 100 --batteryState charged --cellularBars 4 --wifiBars 3`
2. Capture: `xcrun simctl io booted screenshot <file>.png`
3. Screens: lock screen with the widget, lock screen with a saved verse wallpaper, the app's main
   screen, the styles + verse position section, and About. Adding the widget to the simulator's
   lock screen needs a few clicks in the Simulator window (touch and hold > Customize > Lock Screen).
4. Frame with `python3 tools/frame_screenshots.py <raw_dir> <out_dir> 1320 2868` (iPad: `2064 2752`).
   Edit the SHOTS list in the script for the iOS file names and captions. No price words ("free").
5. Copy the iPhone and iPad images into `website/assets/img/` (`iphone-lock-widget.png`,
   `iphone-home.png`, `iphone-wallpaper.png`, `ipad-lock-screen.png`), replace the placeholders in
   `website/index.html` (the HTML comments show the exact markup), bump image `?v=` and deploy.

## 6. Upload and submit

1. Version 1.0.0, build 1: `flutter build ipa --release`, then upload the `.ipa` with Transporter
   or Xcode Organizer (Product > Archive > Distribute App > App Store Connect).
2. In App Store Connect > iOS App 1.0.0: pick the build, upload the screenshots, and click
   **Add for Review**, then **Submit**. Release is set to automatic.

## 7. Later: automatic daily wallpaper through Shortcuts

Add an App Intent, "Get Today's Wallpaper", that returns today's verse image as an
`IntentFile`, so users can build a Shortcuts automation with "Set Wallpaper Photo".
It has to draw the image in Swift (`UIGraphicsImageRenderer`) using the same layout numbers as
`lib/wallpaper/wallpaper_renderer.dart`. When it ships, set `kShortcutsActionAvailable = true`
in `lib/ui/screens/iphone_setup_screen.dart` to show the steps that are already written.

## App Store privacy answers

- Data collection: **"Data Not Collected"**.
- Tracking: No.
- Encryption: `ITSAppUsesNonExemptEncryption = false` is already in Info.plist.
- Photo library: add-only (`NSPhotoLibraryAddUsageDescription`). The app never reads photos.
