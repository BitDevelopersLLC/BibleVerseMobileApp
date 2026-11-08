# Privacy Policy

**Without Price collects no data. None.**

_Last updated: November 8, 2026_

## What we collect

Nothing. Without Price has:

- no account or sign-in,
- no analytics, tracking, or advertising,
- no crash reporting,
- no server. The app never connects to the internet.

All Bible verses are built into the app. Your choices (translation, background color, and
whether the daily lock screen is on) are stored only on your phone and are deleted when you
uninstall the app.

## Android permissions

| Permission | Why |
|---|---|
| `SET_WALLPAPER` | To put the verse on your lock screen. |
| `RECEIVE_BOOT_COMPLETED` | To keep the daily update running after your phone restarts. |
| `WAKE_LOCK` | To let the daily update finish while the screen is off. |
| `FOREGROUND_SERVICE` | Required by Android's background-job library. Not used to show anything. |
| `ACCESS_NETWORK_STATE` | Required by Android's background-job library. It can only tell whether a network exists. It cannot send or receive data. |

The last four come from Android's WorkManager library, which runs the once-a-day update.
The app does **not** have the `INTERNET` permission, so it is technically unable to send data
anywhere.

## iPhone permissions

| Permission | Why |
|---|---|
| Add to Photos | Only when you tap "Save today's wallpaper to Photos." The app can add that one picture. It cannot see your photos. |

The lock screen widget reads your translation and style choice from storage shared only
between the app and its own widget on your phone.

## Children

The app collects no information from anyone, including children.

## Changes

If this policy ever changes, the new version will be published here and in the app's source
code repository.

## Contact

Questions: see [withoutprice.app](https://withoutprice.app).
