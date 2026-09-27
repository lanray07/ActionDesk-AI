#!/usr/bin/env python3
"""Create App Store Connect-ready iPhone and iPad marketing screenshots."""
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter


ROOT = Path(__file__).parent
SOURCE = ROOT / "Generated" / "en-GB"
IPHONE = ROOT / "AppStore" / "en-GB" / "iPhone-6.5"
IPAD = ROOT / "AppStore" / "en-GB" / "iPad-13"


def cover(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    width, height = size
    scale = max(width / image.width, height / image.height)
    resized = image.resize(
        (round(image.width * scale), round(image.height * scale)),
        Image.Resampling.LANCZOS,
    )
    left = (resized.width - width) // 2
    top = (resized.height - height) // 2
    return resized.crop((left, top, left + width, top + height))


def main() -> None:
    IPHONE.mkdir(parents=True, exist_ok=True)
    IPAD.mkdir(parents=True, exist_ok=True)

    sources = sorted(SOURCE.glob("[0-9][0-9]-*.jpg"))
    if len(sources) != 10:
        raise SystemExit(f"Expected 10 source screenshots, found {len(sources)}")

    for source in sources:
        image = Image.open(source).convert("RGB")
        stem = source.name.rsplit("-1260x2736", 1)[0]

        iphone = image.resize((1284, 2778), Image.Resampling.LANCZOS)
        iphone.save(IPHONE / f"{stem}-1284x2778.jpg", quality=95, subsampling=0)

        background = cover(image, (2064, 2752)).filter(ImageFilter.GaussianBlur(34))
        background = ImageEnhance.Brightness(background).enhance(0.63)
        foreground = image.resize((1267, 2752), Image.Resampling.LANCZOS)
        background.paste(foreground, ((2064 - foreground.width) // 2, 0))
        background.save(IPAD / f"{stem}-2064x2752.jpg", quality=95, subsampling=0)

    print(f"Created {len(sources)} iPhone and {len(sources)} iPad screenshots")


if __name__ == "__main__":
    main()
