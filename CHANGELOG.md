# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Today's verse in four public-domain translations (BSB, KJV, WEB, ASV), 168 curated verses.
- Android: an optional daily lock screen wallpaper, set natively in the background.
- iOS: lock screen and home screen widget source, a "Save today's wallpaper to Photos" option,
  and step-by-step setup guides.
- Four wallpaper styles with a live preview.
- An About screen with the privacy promise and translation notices.
- `tools/build_verses.py` to regenerate the bundled verse data from eBible.org.
- Licensed under GPL-3.0.

### Fixed
- Turning on the daily lock screen no longer starts two wallpaper updates at the same moment.
- The verse no longer sits under the large centered clock that Android 15 shows when there are no notifications.
