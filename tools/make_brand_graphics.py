#!/usr/bin/env python3
"""Generate store and website graphics from the logo and the raw screenshots.

Usage:
    python -I tools/make_brand_graphics.py

Inputs (private, not in git):
    media/icon-master.png                  1024 x 1024 full icon (no transparency)
    media/icon-monochrome.png              1024 x 1024 one-color logo on transparent
    media/screenshots/android/raw/*.png    raw phone screenshots

Outputs:
    media/google-play/feature-graphic.png  1024 x 500, Google Play feature graphic
    media/google-play/icon-512.png         512 x 512, Google Play hi-res icon
    media/app-store/icon-1024.png          1024 x 1024, App Store icon (no alpha)
    website/assets/img/...                 logo, favicons, social card, phone images

Requires Pillow. Uses the Georgia font from Windows or macOS.
Store graphics avoid price/promotion words such as "free" (Google Play rejects them).
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
MEDIA = ROOT / "media"
RAW = MEDIA / "screenshots" / "android" / "raw"
SITE_IMG = ROOT / "website" / "assets" / "img"

#: Georgia regular and bold, on Windows or macOS.
FONT_FILES = {
    "georgia.ttf": ("C:/Windows/Fonts/georgia.ttf", "/System/Library/Fonts/Supplemental/Georgia.ttf"),
    "georgiab.ttf": ("C:/Windows/Fonts/georgiab.ttf", "/System/Library/Fonts/Supplemental/Georgia Bold.ttf"),
}
PURPLE = (0x3B, 0x2A, 0x4D)  # logo and "Dawn" top color
PEACH = (0xC9, 0x82, 0x6B)   # "Dawn" bottom color
BEZEL = (20, 16, 26)


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    path = next(p for p in FONT_FILES[name] if Path(p).exists())
    return ImageFont.truetype(path, size)


def gradient(size: tuple[int, int], start: tuple[int, int, int], end: tuple[int, int, int],
             diagonal: bool = False) -> Image.Image:
    """Linear gradient, top to bottom (or top-left to bottom-right when diagonal)."""
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    span = (w + h) if diagonal else h
    for y in range(h):
        for x in range(w):
            t = ((x + y) if diagonal else y) / (span - 1)
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(start, end))
    return img


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.width - 1, img.height - 1), radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def phone(screenshot: Path, height: int) -> Image.Image:
    """A screenshot inside a simple dark phone bezel, on a transparent background."""
    shot = Image.open(screenshot).convert("RGB")
    inner_h = round(height * 0.985)
    shot = shot.resize((round(shot.width * inner_h / shot.height), inner_h), Image.LANCZOS)
    bezel = (height - inner_h) // 2
    body = rounded(Image.new("RGB", (shot.width + 2 * bezel, height), BEZEL), round(height * 0.045))
    body.alpha_composite(rounded(shot, round(height * 0.036)), (bezel, bezel))
    return body


def with_shadow(canvas: Image.Image, item: Image.Image, xy: tuple[int, int], blur: int) -> None:
    """Paste item onto canvas (in place) with a soft drop shadow."""
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    x, y = xy
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x + blur // 3, y + blur, x + item.width + blur // 3, y + item.height + blur), blur * 2, fill=(0, 0, 0, 120))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(blur)))
    canvas.alpha_composite(item, xy)


def recolored_logo(size: int, color: tuple[int, int, int]) -> Image.Image:
    """The one-color logo, recolored and resized (keeps its transparency)."""
    mono = Image.open(MEDIA / "icon-monochrome.png").convert("RGBA")
    mono = mono.crop(mono.getbbox())
    scale = size / max(mono.size)
    mono = mono.resize((round(mono.width * scale), round(mono.height * scale)), Image.LANCZOS)
    solid = Image.new("RGBA", mono.size, (*color, 255))
    solid.putalpha(mono.getchannel("A"))
    return solid


def banner(size: tuple[int, int], tagline: str, footnote: str, out: Path) -> None:
    """Logo, name and tagline on the left; the lock screen phone on the right."""
    w, h = size
    canvas = gradient(size, PURPLE, PEACH, diagonal=True).convert("RGBA")
    draw = ImageDraw.Draw(canvas)
    s = h / 500  # layout scale relative to the 1024 x 500 feature graphic

    logo = recolored_logo(round(110 * s), (255, 255, 255))
    left = round(64 * s)
    top = round((h - 330 * s) / 2)
    canvas.alpha_composite(logo, (left, top))
    draw.text((left, top + round(132 * s)), "Without Price", font=font("georgiab.ttf", round(62 * s)), fill="white")
    draw.multiline_text((left, top + round(214 * s)), tagline, font=font("georgia.ttf", round(27 * s)),
                        fill="white", spacing=round(8 * s))
    draw.text((left, top + round(300 * s)), footnote, font=font("georgia.ttf", round(20 * s)),
              fill=(255, 255, 255, 215))

    # The phone is taller than the banner and cropped, so the big clock and the verse are visible.
    device = phone(RAW / "02-lock-screen.png", round(700 * s))
    with_shadow(canvas, device, (w - device.width - round(70 * s), -round(250 * s)), round(18 * s))
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(out, optimize=True)
    print(f"{out.relative_to(ROOT)}  {canvas.size}")


def save_square(img: Image.Image, size: int, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(out, optimize=True)
    print(f"{out.relative_to(ROOT)}  {size}x{size}")


def main() -> None:
    master = Image.open(MEDIA / "icon-master.png").convert("RGB")

    # Store graphics.
    banner((1024, 500), "A Bible verse on your\nlock screen, every day.",
           "No ads  \u00b7  No tracking  \u00b7  Works offline", MEDIA / "google-play" / "feature-graphic.png")
    save_square(master, 512, MEDIA / "google-play" / "icon-512.png")
    save_square(master, 1024, MEDIA / "app-store" / "icon-1024.png")

    # Website graphics.
    banner((1200, 630), "A Bible verse on your\nlock screen, every day.",
           "Coming soon to iPhone, iPad and Android", SITE_IMG / "social-card.png")
    save_square(master, 180, SITE_IMG / "apple-touch-icon.png")
    save_square(master, 512, SITE_IMG / "icon-512.png")
    save_square(master, 32, SITE_IMG / "favicon-32.png")
    master.save(SITE_IMG / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48)])
    recolored_logo(256, (255, 255, 255)).save(SITE_IMG / "logo-white.png", optimize=True)
    recolored_logo(256, PURPLE).save(SITE_IMG / "logo.png", optimize=True)
    for name in ["02-lock-screen", "05-lock-screen-night", "01-home", "03-styles", "04-about"]:
        out = SITE_IMG / f"android-{name[3:]}.png"
        phone(RAW / f"{name}.png", 900).save(out, optimize=True)
        print(f"{out.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
