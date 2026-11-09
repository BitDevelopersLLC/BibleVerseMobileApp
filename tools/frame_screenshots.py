#!/usr/bin/env python3
"""Place raw phone screenshots on branded backgrounds with captions, for the app stores.

Usage:
    python tools/frame_screenshots.py <raw_dir> <out_dir> [width height] [--set android|ios]

Defaults to 1080 x 1920 (Google Play, 9:16) and the Android captions. For the App Store use
`1320 2868 --set ios` (iPhone 6.9") or `2064 2752 --set ios` (iPad 13").
Requires Pillow. Captions and file order are in SHOT_SETS below. Uses the Georgia Bold font
on Windows or macOS.
"""
import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

#: (raw file, caption, output name), in store order, for each platform.
#: The stores reject price/promotion wording such as "free" in graphics, so captions avoid it.
SHOT_SETS = {
    "android": [
        ("02-lock-screen.png", "A new Bible verse on\nyour lock screen,\nevery day", "01-lock-screen"),
        ("01-home.png", "Four trusted\npublic-domain\ntranslations", "02-translations"),
        ("03-styles.png", "Your colors, and\nwhere the verse\nsits on your screen", "03-styles"),
        ("05-lock-screen-night.png", "Set it once.\nIt changes every\nmorning.", "04-changes-daily"),
        ("04-about.png", "No ads.\nNo tracking.\nNothing collected.", "05-privacy"),
    ],
    # Raw files come from the iOS Simulator (see docs/ios-setup.md, section 5).
    "ios": [
        ("01-lock-widget.png", "A Bible verse on\nyour lock screen,\nevery day", "01-lock-widget"),
        ("02-lock-wallpaper.png", "Or the whole verse,\nfull screen, new\nevery morning", "02-wallpaper"),
        ("03-home.png", "Four trusted\npublic-domain\ntranslations", "03-translations"),
        ("04-styles.png", "Your colors, and\nwhere the verse\nsits on your screen", "04-styles"),
        ("05-shortcuts-guide.png", "Set it up once\nwith the Shortcuts\napp. Step by step.", "05-shortcuts"),
        ("06-about.png", "No ads.\nNo tracking.\nNothing collected.", "06-privacy"),
    ],
}

parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument("raw_dir", type=Path, help="folder with the raw screenshots")
parser.add_argument("out_dir", type=Path, help="folder for the framed images")
parser.add_argument("size", type=int, nargs="*", help="output width and height (default 1080 1920)")
parser.add_argument("--set", dest="shot_set", choices=sorted(SHOT_SETS), default="android",
                    help="which captions and file names to use (default android)")
args = parser.parse_args()
if args.size and len(args.size) != 2:
    parser.error("give both width and height, or neither")

RAW = args.raw_dir
OUT = args.out_dir
OUT.mkdir(parents=True, exist_ok=True)

W, H = args.size if args.size else (1080, 1920)
# Scale from the 1080 x 1920 design by the tighter side, so wide canvases (iPad) keep the caption
# above the screenshot. Phones are width-limited, so their layout is unchanged.
SCALE = min(W / 1080, H / 1920)
TOP = (0x3B, 0x2A, 0x4D)      # icon / Dawn purple
BOTTOM = (0xC9, 0x82, 0x6B)   # Dawn peach
# Georgia Bold: Windows path first, then macOS.
SERIF_FONT = next(p for p in ("C:/Windows/Fonts/georgiab.ttf",
                              "/System/Library/Fonts/Supplemental/Georgia Bold.ttf",
                              "/Library/Fonts/Georgia Bold.ttf") if Path(p).exists())
SERIF = ImageFont.truetype(SERIF_FONT, round(74 * SCALE))

SHOTS = SHOT_SETS[args.shot_set]


def gradient() -> Image.Image:
    img = Image.new("RGB", (W, H))
    px = img.load()
    for y in range(H):
        t = y / (H - 1)
        c = tuple(round(a + (b - a) * t) for a, b in zip(TOP, BOTTOM))
        for x in range(W):
            px[x, y] = c
    return img


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *img.size), radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


base = gradient()
for name, caption, out_name in SHOTS:
    if not (RAW / name).exists():
        print(f"skipping {name} (not found)")
        continue
    canvas = base.copy()
    draw = ImageDraw.Draw(canvas)

    # Caption, centered in the top area.
    box = draw.multiline_textbbox((0, 0), caption, font=SERIF, spacing=round(18 * SCALE), align="center")
    tw, th = box[2] - box[0], box[3] - box[1]
    draw.multiline_text(((W - tw) / 2, (90 + (330 - th / SCALE) / 2) * SCALE), caption, font=SERIF,
                        fill="white", spacing=round(18 * SCALE), align="center")

    # Screenshot with rounded corners, a dark bezel, and a soft shadow.
    shot_h = round(H * 0.74)
    shot = Image.open(RAW / name).convert("RGB")
    shot = shot.resize((round(shot.width * shot_h / shot.height), shot_h), Image.LANCZOS)
    bezel = round(14 * SCALE)
    phone = Image.new("RGB", (shot.width + 2 * bezel, shot.height + 2 * bezel), (20, 16, 26))
    phone = rounded(phone, round(64 * SCALE))
    phone.alpha_composite(rounded(shot, round(50 * SCALE)), (bezel, bezel))

    x, y = (W - phone.width) // 2, round(H * 0.234)
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((x + 10, y + 24, x + phone.width + 10, y + phone.height + 24), 64,
                                             fill=(0, 0, 0, 110))
    shadow = shadow.filter(ImageFilter.GaussianBlur(round(28 * SCALE)))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)
    canvas.alpha_composite(phone, (x, y))

    target = OUT / f"{out_name}.png"
    canvas.convert("RGB").save(target, optimize=True)
    print(target.name, canvas.size)
