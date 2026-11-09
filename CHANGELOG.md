# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
uses [Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-11-09

Android update. The App Store's first release (1.0.0, build 4) already includes these changes.

### Added
- "New verse: Every day / Every hour" setting. Every day stays the default. The Android wallpaper
  and the iOS widget follow it; the rule is the same in Dart, Kotlin and Swift, with tests on all three.
  With Every hour, the Android background job checks every 15 minutes.
- iOS: a "Get Today's Wallpaper" action for the Shortcuts app, so a personal automation can put a
  new full-screen verse wallpaper on the lock screen every morning. The app explains the setup.

### Changed
- On tablets, the app's content sits in a centered column.
- iOS: the lock screen widget centers the verse and uses the largest text that fits.
- iOS: the widget and the app share one copy of the verse rotation, styles and positions (`ios/Shared/`).
- iOS: requires iOS 15 or later (the widget and the Shortcuts action need iOS 17).

## [1.0.0] - 2026-11-08

First Google Play release.

### Added
- Today's verse in four public-domain translations (BSB, KJV, WEB, ASV), 168 curated verses.
- Android: an optional daily lock screen wallpaper, set natively in the background.
- iOS: lock screen and home screen widget source, a "Save today's wallpaper to Photos" option,
  and step-by-step setup guides.
- Four wallpaper styles with a live preview.
- Verse position setting (top, upper middle, lower middle, bottom) so the clock or fingerprint icon never covers the verse.
- An About screen with the privacy promise and translation notices.
- `tools/build_verses.py` to regenerate the bundled verse data from eBible.org.
- Licensed under GPL-3.0.
- withoutprice.app website (coming-soon home page, support page, and privacy policy).

### Changed
- The Android app now asks for only three permissions; two unused ones added by WorkManager were removed.
- Release builds are signed with the Without Price upload key.

### Fixed
- Psalm headings (such as "For the choirmaster. A Psalm of David.") no longer appear before verse 1.
- Turning on the daily lock screen no longer starts two wallpaper updates at the same moment.
- The verse no longer sits under the large centered clock that Android 15 shows when there are no notifications.
