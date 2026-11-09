# iOS setup (do this on the Mac)

## 0. Before starting

Already done from Windows (don't redo): the Apple Developer identifiers (App Group
`group.app.withoutprice`, App IDs `app.withoutprice` and `app.withoutprice.VerseWidget`, both
linked to the group) and the whole App Store Connect listing (text, privacy, age rating, pricing,
availability without China mainland, automatic release). See `docs/app-store-listing.md`.

On the Mac you need: Xcode, Flutter (`flutter doctor` clean for iOS), CocoaPods, and Python 3
with Pillow (`python3 -m pip install pillow`) for the screenshot framing.

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
  `VerseWidgetBundle.swift` (entry point), `VerseTimelineProvider.swift`, `VerseWidgetView.swift`,
  `PrivacyInfo.xcprivacy` and `Assets.xcassets`.
- `ios/Shared/` is synced with **both** Runner and the widget: the verse rotation (`VerseStore.swift`,
  `VerseCadence.swift`), `WallpaperStyle.swift`, `VersePosition.swift` and `SharedSettings.swift`
  (the App Group keys).
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
2. Capture: `xcrun simctl io booted screenshot <file>.png`. Save the raw files in the private
   `media/screenshots/ios/iphone-raw/` and `ipad-raw/` folders with these names:
   `01-lock-widget`, `02-lock-wallpaper`, `03-home`, `04-styles` (Night + Lower),
   `05-shortcuts-guide` (Wallpaper tab, scrolled to the Shortcuts steps) and `06-about`.
3. Adding the widget needs touch-and-hold on the Simulator's lock screen (Customize > Add Widgets).
4. The Simulator draws photo wallpapers as plain black. For `02-lock-wallpaper`, save the verse
   picture from the app, set it as the wallpaper (Photos > Share > Use as Wallpaper), capture the
   lock screen (clock over black), and combine the two with a "screen" blend (Pillow
   `ImageChops.screen(wallpaper, lock_screen)`). The result matches what a real device shows.
5. Frame: `python3 tools/frame_screenshots.py media/screenshots/ios/iphone-raw media/screenshots/ios/iphone-framed 1320 2868 --set ios`
   and the same with `ipad-raw ipad-framed 2064 2752`. Captions avoid price words ("free").
6. Website images: `python3 tools/make_brand_graphics.py --ios-only` writes
   `website/assets/img/iphone-lock-widget.png`, `iphone-home.png`, `iphone-wallpaper.png` and
   `ipad-lock-screen.png` (private files; deploy them with the site).

## 6. Upload and submit

1. Version 1.0.0, build 1: `flutter build ipa --release`, then upload the `.ipa` with Transporter
   or Xcode Organizer (Product > Archive > Distribute App > App Store Connect).
2. In App Store Connect > iOS App 1.0.0: pick the build, upload the screenshots, and click
   **Add for Review**, then **Submit**. Release is set to automatic.

## 7. Daily wallpaper through Shortcuts

iOS doesn't let apps change the wallpaper, and lock screen widgets are small, so the full-screen
verse comes from a Shortcuts automation:

- `ios/WallpaperShortcut/` (synced with Runner only) holds `GetTodaysWallpaperIntent.swift`, the
  App Intent behind the **Get Today's Wallpaper** action, and `WallpaperRenderer.swift`, a port of
  `lib/wallpaper/wallpaper_renderer.dart`. Keep the layout constants of the three renderers (Dart,
  Kotlin, Swift) in sync.
- The action reads the user's translation, style, position and cadence from the App Group
  (`SharedSettings`), which `AppDelegate` fills whenever a setting changes. It draws at the
  screen's native resolution and returns a PNG. It never opens the app and needs iOS 17.
- `verses.json` is in the Runner target's resources as well as the widget's.
- The user-facing steps are in `lib/ui/screens/iphone_setup_screen.dart` and on the support page.
  They were checked on iOS 26.5: Automation > New Automation > Time of Day (Daily, Run Immediately)
  > Create New Shortcut > Get Today's Wallpaper > Set Wallpaper Photo (choose the verse wallpaper,
  Lock Screen only, Show Preview and Crop to Subject off).
- "Set Wallpaper Photo" can only update a wallpaper made from a photo, so users first set a saved
  verse picture as their wallpaper once by hand.
- Shortcuts automations repeat at most daily, so with the "Every hour" setting only the widget
  changes hourly.

To test on the simulator: run the app once, then in Shortcuts build a shortcut with
**Get Today's Wallpaper** followed by **Save to Photos**, run it, and compare the saved picture
with the app's "Save to Photos" image. They should match. `RunnerTests/VerseRotationTests.swift`
covers the rotation rule and the renderer's output size (`xcodebuild test -workspace
Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'`).

## App Store privacy answers

- Data collection: **"Data Not Collected"**.
- Tracking: No.
- Encryption: `ITSAppUsesNonExemptEncryption = false` is already in Info.plist.
- Photo library: add-only (`NSPhotoLibraryAddUsageDescription`). The app never reads photos.
