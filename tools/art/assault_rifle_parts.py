"""Cut the contractor rifle's prop assets. Input: n19/guns/masters (manifest n19-guns).

The original dropped rifle supplies its exact face, magazine and pickup views. Its first
heading lies horizontally on the floor, so changing floor pitch scales only its height.
The newly drawn overhead plate uses 320 part pixels per metre before the rig poses it.
"""
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps

ART = Path("project/features/combat/weapons/art")
NAME = "assault_rifle"


def keyed(path):
    rgb = np.asarray(Image.open(path).convert("RGB")).astype(float)
    red, green, blue = rgb.transpose(2, 0, 1)
    spill = green - np.maximum(red, blue)
    alpha = 255 - np.clip((spill - 8) * 4, 0, 255)
    rgb[:, :, 1] = np.minimum(green, np.maximum(red, blue) + 8)
    rgba = np.dstack((rgb, alpha)).astype(np.uint8)
    rgba[alpha == 0] = 0
    return Image.fromarray(rgba)


def size(im, width, y_factor=1.0):
    height = round(im.height * width / im.width * y_factor)
    return im.convert("RGBa").resize((width, height), Image.Resampling.LANCZOS).convert("RGBA")


def cut(masters):
    out = ART / NAME
    out.mkdir(exist_ok=True)
    raw = keyed(masters / "held_raw.png")
    raw.save(masters / "held_key.png")
    overhead = size(raw.crop(raw.getbbox()), 384)
    ImageOps.expand(overhead, 4).save(out / "held.png")
    sheet = Image.open(ART / "ground_rifle_70.png").convert("RGBA")
    cell = sheet.crop((0, 0, sheet.height, sheet.height))
    side = cell.crop(cell.getbbox())
    side.save(out / "pickup.png")
    size(side, 128).save(out / "icon.png")
    # Visible box below the receiver in heading zero, including its inked outer rim.
    ImageOps.expand(size(side.crop((130, 44, 163, 89)), 45), 2).save(out / "mag.png")
    for form, image in {
        "p70": side,
        "p55": size(side, side.width, math.sin(math.radians(55)) / math.sin(math.radians(70))),
        "icon": size(side, 192),
    }.items():
        image.save(ART / "showcase" / form / (NAME + ".png"))


if __name__ == "__main__":
    cut(Path(sys.argv[1]))
