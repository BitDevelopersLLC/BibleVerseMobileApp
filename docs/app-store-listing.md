# App Store listing

Values to paste into App Store Connect for version 1.0.0. Graphics are in the private `media/`
folder (not in this repository). iPhone and iPad screenshots must be taken in the iOS simulator
on the Mac (see `docs/ios-setup.md`).

## Identifiers (Apple Developer account > Certificates, Identifiers & Profiles)

| Identifier | Value |
|---|---|
| App Group | `group.app.withoutprice` |
| App ID (the app) | `app.withoutprice`, with the **App Groups** capability, assigned to the group above |
| App ID (the widget) | `app.withoutprice.VerseWidget`, with **App Groups**, same group |

## App information

| Field | Value |
|---|---|
| Name (27 of 30) | `Without Price: Bible Verses` |
| Subtitle (30 of 30) | `Daily Verse Lock Screen Widget` |
| Primary language | English (U.S.) |
| Bundle ID | `app.withoutprice` |
| SKU | `withoutprice-ios` (private, any unique text) |
| Primary category | Reference |
| Secondary category | Lifestyle |
| Content rights | **Yes**, it contains third-party content and I have the necessary rights (the Bible translations are public domain) |
| Age rating | Answer **None / No** to everything. Expected: **4+** |

## Version 1.0.0 page

**Promotional text** (159 of 170; can be changed anytime without review)

```
A new Bible verse under your clock every day. No ads, no account, nothing collected. Add the lock screen widget once and let God's Word greet you each morning.
```

**Keywords** (97 of 100; words already in the name and subtitle are indexed automatically, so they aren't repeated)

```
scripture,devotional,christian,faith,god,jesus,psalm,kjv,wallpaper,inspiration,quotes,hope,gospel
```

**Description**

```
Start every day with God's Word. Without Price puts a new Bible verse on your lock screen, so the first thing you see when you pick up your iPhone or iPad is Scripture.

"Come, buy wine and milk without money and without price." (Isaiah 55:1)

That verse is our promise. This app isn't trying to get anything from you.

• Free forever. No price, no subscription, no "premium" version.
• No ads. Nothing competes with the verse for your attention.
• Nothing collected. No account, no analytics, no tracking.
• Works offline. Every verse is built into the app.
• Open source. Anyone can read the code and check these promises.

TWO WAYS TO SEE TODAY'S VERSE
• Lock screen widget: add it once, and it shows a new verse by itself.
• Full-screen wallpaper: save today's verse as a beautiful wallpaper, then let Apple's Shortcuts app put a new one on your lock screen every morning. The app shows you how, step by step.

FEATURES
• A new verse every day (or every hour, if you like), automatically
• 168 hand-picked verses about hope, strength, peace, and God's love, each short enough for a lock screen
• Four trusted public-domain translations: Berean Standard Bible (BSB), King James Version (KJV), World English Bible (WEB), and American Standard Version (ASV)
• Four calm background styles: Dawn, Night, Olive, and Stone
• Choose where the verse sits on your wallpaper: top, upper middle, lower middle, or bottom
• Home screen and StandBy widgets too

Questions or ideas? Write to hello@withoutprice.app. We read every message.

Bible text from eBible.org. "World English Bible" is a trademark of eBible.org.
```

| Field | Value |
|---|---|
| Support URL | `https://withoutprice.app/support.html` |
| Marketing URL | `https://withoutprice.app` |
| Copyright | `2026 BitDevelopers LLC` |
| Version | 1.0.0 |

## App Privacy

**Data collection:** "No, we do not collect data from this app." Resulting label: **Data Not Collected**.
Privacy policy URL: `https://withoutprice.app/privacy.html`

## Pricing and availability

Price: **Free** (USD 0.00). Availability: all countries, or start with the United States.

## Graphics

| Field | File |
|---|---|
| App icon | Comes from the build (`media/app-store/icon-1024.png` is the source) |
| iPhone 6.9" screenshots (1320 x 2868) | Taken on the Mac, then framed with `tools/frame_screenshots.py raw out 1320 2868` |
| iPad 13" screenshots (2064 x 2752) | Taken on the Mac, iPad Pro 13" simulator |

Apple rejects screenshots that show another platform, so the Android screenshots can't be reused.
