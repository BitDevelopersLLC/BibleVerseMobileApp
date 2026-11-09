# Google Play listing

Everything to paste into Play Console for version 1.0.0. Graphics are in the private `media/`
folder (not in this repository).

## Release file

`mobile/build/app/outputs/bundle/release/app-release.aab`, built with
`flutter build appbundle --release` and signed with the upload key referenced in the gitignored
`mobile/android/key.properties`. Turn on **Play App Signing** when creating the app (Google
holds the app signing key; the upload key can be reset if it's ever lost).

## Main store listing

**App name** (27 of 30 characters)

```
Without Price: Bible Verses
```

**Short description** (78 of 80 characters)

```
A new Bible verse on your lock screen every day. No ads, no tracking, offline.
```

**Full description** (under 4,000 characters)

```
Start every day with God's Word. Without Price puts a new Bible verse on your lock screen each morning, so the first thing you see when you pick up your phone is Scripture.

"Come, buy wine and milk without money and without price." (Isaiah 55:1)

That verse is our promise. This app isn't trying to get anything from you.

• Free forever. No price, no subscription, no "premium" version.
• No ads. Nothing competes with the verse for your attention.
• Nothing collected. No account, no analytics, no tracking. The app doesn't even have permission to use the internet.
• Works offline. Every verse is built into the app.
• Open source. Anyone can read the code and check these promises.

HOW IT WORKS
1. Pick a translation and a background.
2. Turn on "Put a new verse on my lock screen every day."
3. That's it. Each morning, today's verse appears on your lock screen. Your home screen stays the same.

FEATURES
• A new verse every day, automatically, on your lock screen
• 168 hand-picked verses about hope, strength, peace, and God's love, each short enough for a lock screen
• Four trusted public-domain translations: Berean Standard Bible (BSB), King James Version (KJV), World English Bible (WEB), and American Standard Version (ASV)
• Four calm background styles: Dawn, Night, Olive, and Stone
• Placed below the clock, so the verse is never hidden
• Light on battery: one small update a day

PRIVACY
Without Price asks for only three permissions: to set your lock screen wallpaper, and two that let the daily update run and survive a restart. It cannot send data anywhere. Read our privacy policy at withoutprice.app/privacy.html.

Questions or ideas? Write to hello@withoutprice.app. We read every message.

Bible text from eBible.org. "World English Bible" is a trademark of eBible.org.
```

## Graphics

| Field | File |
|---|---|
| App icon (512 x 512) | `media/google-play/icon-512.png` |
| Feature graphic (1024 x 500) | `media/google-play/feature-graphic.png` |
| Phone screenshots (1080 x 1920) | `media/screenshots/android/google-play/01-lock-screen.png` to `05-privacy.png`, in that order |

## Store settings

| Setting | Value |
|---|---|
| App or game | App |
| Free or paid | Free (this can never be changed to paid later, which fits the promise) |
| Category | Books & Reference |
| Tags | Bible, Religion and spirituality (pick the closest offered) |
| Email | hello@withoutprice.app |
| Website | https://withoutprice.app |
| Privacy policy | https://withoutprice.app/privacy.html |

## App content (Policy > App content)

| Form | Answer |
|---|---|
| Privacy policy | https://withoutprice.app/privacy.html |
| Ads | **No**, the app does not contain ads |
| App access | All functionality is available without special access (no login) |
| Content rating | Fill in the IARC questionnaire. Category: "All Other App Types" (or "Reference, News, or Educational" if offered). Answer **No** to every question about violence, sexuality, language, controlled substances, gambling, user interaction, sharing location, and digital purchases. Expected rating: **Everyone / PEGI 3**. |
| Target audience | **13 and over** (13-15, 16-17, 18+). Including under-13 age groups puts the app under the Families policy, which adds requirements without benefit here. The app is still fine for children to use. |
| News app | No |
| Data safety | See below |
| Government app | No |
| Financial features | None |
| Health | None |
| Foreground service permissions | Not applicable (removed from the manifest) |

## Data safety

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not shown once you answer No above |
| Do you provide a way for users to request that their data is deleted? | Not shown once you answer No above |

Resulting label: **"No data collected"** and **"No data shared with third parties."**

Why this is accurate: the app has no `INTERNET` permission, no analytics or crash-reporting SDKs,
and no account. Settings stay on the device.

## Release

1. Create the app in Play Console: name "Without Price: Bible Verses", default language English (United States), App, Free.
2. Complete **App content** and the **Store listing** above.
3. **Testing > Internal testing**: upload the `.aab`, add yourself as a tester, install it from the Play link, and check it on a real phone (the Samsung).
4. **Production**: promote the same release. Countries: all, or start with the United States.
5. Release notes for 1.0.0: "First release: a new Bible verse on your lock screen every day."
