#!/usr/bin/env python3
"""Place raw phone screenshots on branded backgrounds with captions, for the app stores.

Usage:
    python -I tools/frame_screenshots.py <raw_dir> <out_dir> [width height]

Defaults to 1080 x 1920 (Google Play, 9:16). For the App Store 6.9" size use 1320 2868.
Requires Pillow. Captions and file order are in SHOTS below. Uses the Georgia Bold font
on Windows or macOS.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RAW = Path(sys.argv[1])
OUT = Path(sys.argv[2])
OUT.mkdir(parents=True, exist_ok=True)

W, H = (int(sys.argv[3]), int(sys.argv[4])) if len(sys.argv) == 5 else (1080, 1920)
SCALE = W / 1080
TOP = (0x3B, 0x2A, 0x4D)      # icon / Dawn purple
BOTTOM = (0xC9, 0x82, 0x6B)   # Dawn peach
# Georgia Bold: Windows path first, then macOS.
SERIF_FONT = next(p for p in ("C:/Windows/Fonts/georgiab.ttf",
                              "/System/Library/Fonts/Supplemental/Georgia Bold.ttf",
                              "/Library/Fonts/Georgia Bold.ttf") if Path(p).exists())
SERIF = ImageFont.truetype(SERIF_FONT, round(74 * SCALE))

#: (raw file, caption, output name), in store order.
#: Google Play rejects price/promotion wording such as "free" in graphics, so captions avoid it.
SHOTS = [
    ("02-lock-screen.png", "A new Bible verse on\nyour lock screen,\nevery day", "01-lock-screen"),
    ("01-home.png", "Four trusted\npublic-domain\ntranslations", "02-translations"),
    ("03-styles.png", "Your colors, and\nwhere the verse\nsits on your screen", "03-styles"),
    ("05-lock-screen-night.png", "Set it once.\nIt changes every\nmorning.", "04-changes-daily"),
    ("04-about.png", "No ads.\nNo tracking.\nNothing collected.", "05-privacy"),
]


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
