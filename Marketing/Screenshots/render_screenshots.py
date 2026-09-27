#!/usr/bin/env python3
"""Render localized, text-editable App Store compositions from a locale manifest."""
from __future__ import annotations
import argparse, json, textwrap
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

ROOT = Path(__file__).parent
W, H = 1260, 2736
FONT_BOLD = Path("C:/Windows/Fonts/seguisb.ttf")
FONT_REGULAR = Path("C:/Windows/Fonts/segoeui.ttf")

def font(path: Path, size: int): return ImageFont.truetype(str(path), size)

def fitted_cover(image: Image.Image) -> Image.Image:
    ratio = max(W / image.width, H / image.height)
    image = image.resize((int(image.width * ratio), int(image.height * ratio)), Image.Resampling.LANCZOS)
    left, top = (image.width - W) // 2, (image.height - H) // 2
    return image.crop((left, top, left + W, top + H)).convert("RGB")

def multiline(draw, text, xy, max_chars, chosen_font, fill, spacing=14):
    wrapped = textwrap.fill(text, width=max_chars)
    draw.multiline_text(xy, wrapped, font=chosen_font, fill=fill, spacing=spacing)

def phone_ui(canvas: Image.Image, screen: dict, index: int):
    draw = ImageDraw.Draw(canvas)
    x0, y0, x1, y1 = 315, 1240, 945, 2660
    draw.rounded_rectangle((x0-14, y0-14, x1+14, y1+14), radius=92, fill=(15,20,23))
    draw.rounded_rectangle((x0, y0, x1, y1), radius=78, fill=(246,247,245))
    draw.rounded_rectangle((520, y0+24, 740, y0+58), radius=18, fill=(18,22,23))
    draw.text((x0+48, y0+98), "ActionDesk", font=font(FONT_BOLD, 46), fill=(26,39,37))
    draw.text((x0+48, y0+166), screen["proof"], font=font(FONT_BOLD, 34), fill=(31,66,61))
    draw.text((x0+48, y0+222), screen["detail"], font=font(FONT_REGULAR, 25), fill=(82,91,88))
    colors = [(236,242,239), (242,237,226), (234,239,246)]
    labels = ["WHAT YOU NEED TO DO", "IMPORTANT DATE", "SUGGESTED ACTION"]
    contents = ["Review the document details", "Due soon", "Set a reminder"]
    if index == 6: labels, contents = ["VOICE REQUEST", "RECOGNIZED TEXT", "CONFIRM FIRST"], ["Listening…", "What's due this week?", "No action taken yet"]
    if index == 9: labels, contents = ["LOCAL STORAGE", "PRIVACY LOCK", "YOUR CONTROL"], ["Protected on this device", "Device authentication", "Export or delete data"]
    y = y0 + 320
    for n in range(3):
        draw.rounded_rectangle((x0+42, y, x1-42, y+230), radius=30, fill=colors[n])
        draw.text((x0+72, y+38), labels[n], font=font(FONT_BOLD, 20), fill=(44,104,94))
        multiline(draw, contents[n], (x0+72, y+86), 27, font(FONT_BOLD, 31), (31,37,36), 8)
        y += 258
    draw.rounded_rectangle((x0+42, y1-180, x1-42, y1-92), radius=40, fill=(24,107,94))
    draw.text((x0+185, y1-157), "Take action", font=font(FONT_BOLD, 27), fill="white")

def render(screen: dict, index: int, out_dir: Path):
    bg = fitted_cover(Image.open(ROOT / "Backgrounds" / screen["background"]))
    bg = ImageEnhance.Brightness(bg).enhance(.82).filter(ImageFilter.GaussianBlur(.35))
    overlay = Image.new("RGBA", (W, H), (0,0,0,0))
    od = ImageDraw.Draw(overlay)
    od.rectangle((0,0,W,1120), fill=(244,244,238,238))
    od.rectangle((0,1050,W,H), fill=(242,244,240,75))
    canvas = Image.alpha_composite(bg.convert("RGBA"), overlay).convert("RGB")
    draw = ImageDraw.Draw(canvas)
    multiline(draw, screen["headline"], (82, 112), 24, font(FONT_BOLD, 92), (20,41,38), 4)
    multiline(draw, screen["support"], (86, 430), 36, font(FONT_REGULAR, 42), (52,67,63), 12)
    phone_ui(canvas, screen, index)
    out_dir.mkdir(parents=True, exist_ok=True)
    canvas.save(out_dir / f"{screen['id']}-1260x2736.jpg", quality=94, subsampling=0)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", nargs="?", default=str(ROOT / "manifest.en-GB.json"))
    parser.add_argument("--out", default=str(ROOT / "Generated" / "en-GB"))
    args = parser.parse_args()
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    for index, screen in enumerate(manifest["screens"]): render(screen, index, Path(args.out))
    print(f"Rendered {len(manifest['screens'])} screenshots to {args.out}")

if __name__ == "__main__": main()

