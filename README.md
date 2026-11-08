# Without Price

> "Come, buy wine and milk without money and without price." (Isaiah 55:1)

**Without Price** puts a Bible verse on your phone's lock screen, a new one every day.

- **Free forever.** No price, no subscription, no "premium."
- **No ads, no account, no tracking.** The app collects nothing. See [PRIVACY.md](PRIVACY.md).
- **Fully offline.** The verses are built into the app.
- **Open source**, so anyone can check these promises.

| Platform | How the verse reaches the lock screen |
|---|---|
| Android | The app sets the lock screen wallpaper itself and changes it every day. The home screen is left alone. |
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
  ios/VerseWidgetSources/                WidgetKit lock screen widget (see docs/ios-setup.md)
  test/                                  Unit and widget tests
tools/
  verse_refs.txt                         The curated verse list
  build_verses.py                        Builds mobile/assets/verses.json from eBible.org
docs/ios-setup.md                        Xcode steps for the widget extension
```

### One rule, three languages

The verse of the day is `(days since 1970-01-01 for the local date) mod (number of verses)`.
It is implemented in Dart (`verse_library.dart`), Kotlin (`DailyVerse.kt`), and Swift
(`VerseStore.swift`), so the app, the Android wallpaper, and the iOS widget always agree.
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

iOS needs a one-time Xcode setup for the widget extension: see [docs/ios-setup.md](docs/ios-setup.md).

### Rebuilding the verse data

Download and unzip each translation's verse-per-line archive into its own folder outside the
repository, then run the build script:

```bash
# https://ebible.org/Scriptures/engbsb_vpl.zip   -> ~/ebible/engbsb/
# https://ebible.org/Scriptures/eng-kjv_vpl.zip  -> ~/ebible/eng-kjv/
# https://ebible.org/Scriptures/eng-web_vpl.zip  -> ~/ebible/eng-web/
# https://ebible.org/Scriptures/eng-asv_vpl.zip  -> ~/ebible/eng-asv/
python -I tools/build_verses.py ~/ebible
```

## Privacy, verified

The Android release build has **no `INTERNET` permission**, so it cannot send or receive
anything. You can check this yourself:

```bash
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

See [PRIVACY.md](PRIVACY.md) for every permission and what it is for.
