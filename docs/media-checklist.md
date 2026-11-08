# Media checklist

Every image needed for the app, both stores, and withoutprice.app, with exact sizes.
Create the **logo first**: everything else is built from it.

## 1. Logo and app icon (make these first)

| File | Size | Notes |
|---|---|---|
| `icon-master.png` | 1024 x 1024 | The full icon: symbol on its background, square corners. Each store rounds the corners itself. **No transparency** (Apple rejects it). |
| `icon-foreground.png` | 1024 x 1024 | Android adaptive icon: the symbol only, on a **transparent** background. Keep the symbol inside the **center 66%** circle, because Android crops the edges into different shapes. |
| `icon-monochrome.png` | 1024 x 1024 | Android 13+ "themed icons": the symbol in **one solid color** on transparent. The phone recolors it. |
| Background color | hex value | The solid color behind the adaptive icon foreground, e.g. `#3B2A4D`. |
| `logo.svg` | vector | Symbol, or symbol plus "Without Price" wordmark, for the website. |

Design tips:
- One simple symbol, **no words** in the icon. It must still read at 48 x 48 pixels.
- Check it on light and dark backgrounds.
- The app's default "Dawn" colors are `#3B2A4D` (deep purple) to `#C9826B` (warm peach). Using them makes the icon, screenshots, and lock screen look like one brand.
- Bible-verse apps mostly use crosses, open books, and doves. Something different will stand out.
  Ideas from Isaiah 55:1 ("come to the waters... without money and without price"):
  a cup, a water drop, an open hand offering something, or a sunrise ("new every morning").
- If you use an AI image tool, make sure you have the rights to the result, and redraw it as a clean vector.

Once these exist, the in-app icons for every Android and iOS size are generated automatically
with `flutter_launcher_icons`.

## 2. Google Play

| Asset | Size | Required | Notes |
|---|---|---|---|
| App icon | 512 x 512 PNG | Yes | Exported from `icon-master.png`. 32-bit PNG, max 1 MB. |
| Feature graphic | 1024 x 500 JPG or PNG | Yes | Banner at the top of the listing. No transparency. Keep key content away from the edges. |
| Phone screenshots | 1080 x 1920 (9:16) | 2 required, 4-8 recommended | **The long side may be at most twice the short side.** Raw modern-phone screenshots (1080 x 2400) are too tall, so place them inside a 9:16 design with a caption. |
| Tablet screenshots | 7" and 10" | Optional | Skip for version 1. |
| Promo video | YouTube link | Optional | Skip for version 1. |

Text: title (30 characters), short description (80), full description (4,000).

## 3. Apple App Store

| Asset | Size | Required | Notes |
|---|---|---|---|
| App icon | 1024 x 1024 PNG | Yes | `icon-master.png`. No transparency, no rounded corners. |
| iPhone 6.9" screenshots | 1320 x 2868 portrait | 1 required, up to 10 | Apple scales these down for smaller iPhones. Take them on the Mac in the iPhone Pro Max simulator. |
| iPad screenshots | 2064 x 2752 | Only if the app runs on iPad | Recommendation: make version 1 **iPhone-only**, so no iPad screenshots are needed. |
| App preview video | | Optional | Skip for version 1. |

Text: name (30 characters), subtitle (30), promotional text (170), description (4,000), keywords (100).

## 4. Screenshot set (same story on both stores)

Each screenshot is a real app screen placed on a branded background with a short caption above it.

1. **Lock screen with a verse**: "A new Bible verse on your lock screen, every day"
2. **Today screen**: "Four trusted public-domain translations"
3. **Background styles and preview**: "Choose the look you love"
4. **About / promise screen**: "Free forever. No ads. Nothing collected."
5. iPhone only: **lock screen widget**: "A verse under your clock"

Raw screens:
- Android: captured from the Pixel 7 emulator. Claude can capture these.
- iPhone: captured on the Mac in the iOS simulator, after the widget is set up.

## 5. Website (withoutprice.app)

| Asset | Size | Notes |
|---|---|---|
| Logo | `logo.svg` | Header. |
| Favicon | 512 x 512 PNG from the icon | Claude generates the smaller sizes. |
| Social share image | 1200 x 630 PNG | Shown when the link is shared in messages and social media. Can reuse the feature graphic design. |
| Hero image | about 1200 px wide | A phone showing the lock screen verse, the main picture on the page. |
| Store badges | official files | Use Apple's and Google's official badges, only once the listings exist. Until then, the page says "Coming soon." |
