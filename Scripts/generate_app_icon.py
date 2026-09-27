#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw

OUT = Path(__file__).parents[1] / "ActionDeskAI" / "Assets.xcassets" / "AppIcon.appiconset"
SIZES = {"icon-20@2x.png":40,"icon-20@3x.png":60,"icon-29@2x.png":58,"icon-29@3x.png":87,"icon-40@2x.png":80,"icon-40@3x.png":120,"icon-60@2x.png":120,"icon-60@3x.png":180,"icon-20@1x-ipad.png":20,"icon-20@2x-ipad.png":40,"icon-29@1x-ipad.png":29,"icon-29@2x-ipad.png":58,"icon-40@1x-ipad.png":40,"icon-40@2x-ipad.png":80,"icon-76@1x.png":76,"icon-76@2x.png":152,"icon-83.5@2x.png":167,"icon-1024.png":1024}

canvas = Image.new("RGB", (1024,1024), (20,105,92)); draw = ImageDraw.Draw(canvas)
draw.rounded_rectangle((238,150,786,874), radius=92, fill=(250,250,246))
draw.rounded_rectangle((314,282,710,330), radius=24, fill=(151,184,174))
draw.rounded_rectangle((314,402,620,450), radius=24, fill=(151,184,174))
draw.line((350,606,455,710,690,470), fill=(20,105,92), width=72, joint="curve")
for name, size in SIZES.items(): canvas.resize((size,size), Image.Resampling.LANCZOS).save(OUT/name)
print(f"Generated {len(SIZES)} app icons")

