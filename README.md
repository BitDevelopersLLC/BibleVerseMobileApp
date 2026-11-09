# Without Price

> "Come, buy wine and milk without money and without price." (Isaiah 55:1)

**Without Price** puts a Bible verse on your phone's lock screen, a new one every day (or every hour, if you choose).

- **Free forever.** No price, no subscription, no "premium."
- **No ads, no account, no tracking.** The app collects nothing. See [PRIVACY.md](PRIVACY.md).
- **Fully offline.** The verses are built into the app.
- **Open source** (GPL-3.0), so anyone can check these promises.

| Platform | How the verse reaches the lock screen |
|---|---|
| Android | The app sets the lock screen wallpaper itself and changes it every day or every hour. The home screen is left alone. |
| iPhone | A lock screen widget (recommended), or a full-screen verse wallpaper you save to Photos and set in a few taps. Apple does not let apps change the wallpaper directly. |

Website: [withoutprice.app](https://withoutprice.app)

## Translations

All public domain, from [eBible.org](https://ebible.org):

| Code | Translation |
|---|---|
| BSB | Berean Standard Bible (default) |
| KJV | King James Version |
| WEB | World English Bible ("World English Bible" is a trademark of eBible.org) |
| ASV | American Standard Version |

There are 168 curated verses, chosen to be short enough for a lock screen. The list is in
[`tools/verse_refs.txt`](tools/verse_refs.txt).

## Project structure

```
mobile/                                  Flutter app (Android + iOS)
  lib/
    main.dart, app.dart                  Startup and root widget
    data/                                Verse library and saved settings
    platform/lock_screen_channel.dart    Dart side of the native lock screen bridge
    wallpaper/                           Wallpaper styles and renderer (preview + iOS image)
    ui/screens/, ui/widgets/             Screens and reusable widgets
  android/app/src/main/kotlin/app/withoutprice/
    lockscreen/                          Method channel, preferences, scheduler, background worker
    verses/                              Bundled data access and the daily-verse rule
    wallpaper/                           Native wallpaper renderer and styles
  ios/Runner/AppDelegate.swift           Shares settings with the widget via an App Group
  ios/Shared/                            Verse rotation, styles and settings used by the app and widget
  ios/VerseWidget/                       WidgetKit lock screen widget
  ios/WallpaperShortcut/                 "Get Today's Wallpaper" action for the Shortcuts app
  test/                                  Unit and widget tests
tools/
  verse_refs.txt                         The curated verse list
  build_verses.py                        Builds mobile/assets/verses.json from eBible.org
website/                                 withoutprice.app (static HTML/CSS, no scripts or trackers)
```

The app's name and logo, the screenshots, and the website images are brand assets. They are kept
out of this repository and are not covered by the GPL.

### One rule, three languages

The current verse is `slot mod (number of verses)`, where the slot is the number of days since
1970-01-01 for the local date (a new verse every day, the default) or that number times 24 plus
the local hour (a new verse every hour). It is implemented in Dart (`verse_cadence.dart`,
`verse_library.dart`), Kotlin (`VerseCadence.kt`, `DailyVerse.kt`), and Swift
(`VerseCadence.swift`, `VerseStore.swift`), so the app, the Android wallpaper, the iOS widget and
the iOS Shortcuts action always agree.
The wallpaper styles and layout constants are likewise mirrored between Dart, Kotlin and Swift.
Each file says which others to update.

## Building

Requirements: Flutter 3.41+ (Dart 3.11+). For iOS: Xcode on macOS.

```bash
cd mobile
flutter pub get
flutter analyze        # must report no issues
flutter test
flutter run            # on a device or emulator
```

For iOS, run `pod install` in `mobile/ios` once, then open `mobile/ios/Runner.xcworkspace`. The
project already includes the widget extension (`VerseWidgetExtension`) and the App Group
`group.app.withoutprice`. To build your own copy, choose your team under Signing & Capabilities
for both the Runner and VerseWidgetExtension targets, and use your own bundle IDs and App Group.

### Rebuilding the verse data

Download and unzip each translation's verse-per-line archive into its own folder outside the
repository, then run the build script:

```bash
# https://ebible.org/Scriptures/engbsb_vpl.zip   -> ~/ebible/engbsb/
# https://ebible.org/Scriptures/eng-kjv_vpl.zip  -> ~/ebible/eng-kjv/
# https://ebible.org/Scriptures/eng-web_vpl.zip  -> ~/ebible/eng-web/
# https://ebible.org/Scriptures/eng-asv_vpl.zip  -> ~/ebible/eng-asv/
# Also each translation's USFM archive, used to remove Psalm headings from verse 1:
# https://ebible.org/Scriptures/engbsb_usfm.zip  -> ~/ebible/engbsb_usfm/   (same for eng-kjv, eng-web, eng-asv)
python -I tools/build_verses.py ~/ebible
```

## Privacy, verified

The Android release build has **no `INTERNET` permission**, so it cannot send or receive
anything. You can check this yourself:

```bash
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

See [PRIVACY.md](PRIVACY.md) for every permission and what it is for.

## License

Copyright (C) 2026 BitDevelopers LLC

Without Price is free software: you can redistribute it and/or modify it under the terms of the
[GNU General Public License v3.0](LICENSE) as published by the Free Software Foundation.
Anyone who distributes a modified version must also share its source code under the same license.

The bundled Bible translations are in the public domain. "World English Bible" is a trademark of eBible.org.
