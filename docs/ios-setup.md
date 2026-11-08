# iOS setup (do this on the Mac)

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

1. Open `mobile/ios/Runner.xcworkspace` in Xcode.
2. Runner target > Signing & Capabilities: Team = BitDevelopers LLC. Bundle ID `app.withoutprice`.
3. Add the **App Groups** capability and create `group.app.withoutprice`.
4. Drag `ios/VerseWidgetSources/PrivacyInfo.xcprivacy` into the Runner group, with target **Runner** checked.

## 3. Create the widget extension

1. File > New > Target > **Widget Extension**.
2. Product name **VerseWidget**. Uncheck "Include Live Activity", "Include Control" and "Include Configuration App Intent".
3. When asked to activate the scheme, choose Activate.
4. Delete the template `.swift` files Xcode generated in `ios/VerseWidget/` (move them to Trash).
5. Add every file in `ios/VerseWidgetSources/` to the **VerseWidget** target:
   `VerseWidgetBundle.swift` (entry point), `VerseTimelineProvider.swift`, `VerseStore.swift`,
   `VerseWidgetView.swift`, `WidgetStyle.swift`, and `PrivacyInfo.xcprivacy`.
6. Add `mobile/assets/verses.json` to the **VerseWidget** target as a reference, not a copy,
   so it stays in sync with the build script. Leave "Copy items if needed" unchecked.
7. VerseWidget target > General: Minimum Deployments **iOS 17.0**.
8. VerseWidget target > Signing & Capabilities: same team, add **App Groups** > `group.app.withoutprice`.
   Its bundle ID should be `app.withoutprice.VerseWidget`.
9. Runner target > Build Phases: make sure **Embed Foundation Extensions** contains VerseWidget.appex
   and runs *before* "Thin Binary". (Flutter projects sometimes fail with a "cycle" error otherwise.)

## 4. Test

- Run on a real iPhone. Lock it, touch and hold the lock screen, then Customize > Lock Screen > tap the widget box > Without Price.
- In the app, change the translation and check that the widget updates.
- Check the wallpaper feature: style > Save to Photos > set it through the lock screen editor.

## 5. Later: automatic daily wallpaper through Shortcuts

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
