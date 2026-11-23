"""Bake two yard-floor stamps from the shipped ink, drum lid and retaining ring."""

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageOps

PROJECT = Path(__file__).resolve().parents[2] / "project"
CITY = PROJECT / "features/city/art"
YARD = PROJECT / "boot/prologue/art/torn_line"
LANCZOS = Image.Resampling.LANCZOS


def drum_burn():
    """Lift the centre out of the city's hatched soot where a fallen drum protected the floor."""
    soot = Image.open(CITY / "decals/scorch_b.png").convert("RGBA")
    y, x = np.mgrid[:soot.height, :soot.width]
    x, y = (x - 116) / 48, (y - 122) / 34
    angle = np.arctan2(y, x)
    rim = 1 + 0.06 * np.cos(3 * angle) + 0.035 * np.sin(7 * angle)
    density = np.clip((np.hypot(x, y) - rim) * 8 + 0.15, 0.05, 1)
    soot.putalpha(Image.fromarray(np.rint(np.asarray(soot.getchannel("A")) * density).astype("uint8")))
    return soot.crop(soot.getbbox())


def drum_spill():
    """The loose lid and two side-on coils use the pen edges already printed on the drum art."""
    drums = Image.open(CITY / "props/dock_oil_drums.png").convert("RGBA")
    lid = drums.crop((1, 1, 53, 54))
    mask = Image.new("L", lid.size)
    ImageDraw.Draw(mask).ellipse((0, 0, 51, 52), fill=255)
    lid = ImageOps.colorize(ImageOps.grayscale(lid), "#211d22", "#c3b7a1").convert("RGBA")
    lid.putalpha(mask)
    ring = Image.open(YARD / "drum_ring.png").convert("RGBA").resize((13, 26), LANCZOS)
    coil = Image.new("RGBA", (39, 30))
    for turn in range(6):
        coil.alpha_composite(ring, (turn * 5, 3 - turn // 2))
    spill = Image.new("RGBA", (144, 83))
    spill.alpha_composite(lid.rotate(17, Image.Resampling.BICUBIC, expand=True), (0, 4))
    spill.alpha_composite(coil.rotate(-21, Image.Resampling.BICUBIC, expand=True), (78, 4))
    spill.alpha_composite(coil.rotate(32, Image.Resampling.BICUBIC, expand=True), (98, 37))
    return spill.crop(spill.getbbox())


if __name__ == "__main__":
    drum_burn().save(YARD / "drum_burn.png")
    drum_spill().save(YARD / "drum_spill.png")
