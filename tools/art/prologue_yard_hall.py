"""Cut the two n28 burning hall bays (white key, trimmed to alpha) for the arched_line stage.

python tools/art/prologue_yard_hall.py [--sources DIR]   (writes hall_burst_bay.png, hall_collapsed_bay.png)
"""

import argparse
import colorsys
from pathlib import Path

import numpy as np
from PIL import Image

import prologue_yard_cut as cut
from prologue_yard_arched import despeckle

HERE = Path(__file__).resolve().parent
OUT = HERE.parents[1] / "project/boot/prologue/art/arched_line"
SHADOW = (0x21, 0x1E, 0x1C)
WHITE = (255, 255, 255)
MARGIN = 4
CUTS = {"burning-burst-bay": "hall_burst_bay", "burning-collapsed-bay": "hall_collapsed_bay"}
SHIPPED = {"hall_burst_bay": "line_fire/burst_bay.png", "hall_collapsed_bay": "line_fire/collapsed_bay.png"}


def trimmed(rgba):
    ys, xs = np.where(rgba[..., 3] > 0)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    out = np.zeros((y1 - y0 + 2 * MARGIN, x1 - x0 + 2 * MARGIN, 4), np.uint8)
    out[MARGIN : MARGIN + y1 - y0, MARGIN : MARGIN + x1 - x0] = rgba[y0:y1, x0:x1]
    return out


def red_share(rgba):
    """Share of fire pixels (saturation > 0.5, value > 0.5, opaque) whose hue is under 18 degrees."""
    rgb = rgba[..., :3].astype(np.float32) / 255
    top, low = rgb.max(axis=2), rgb.min(axis=2)
    sat = (top - low) / np.maximum(top, 1e-6)
    fire = (sat > 0.5) & (top > 0.5) & (rgba[..., 3] > 128)
    if not fire.any():
        return 0.0
    hues = np.array([colorsys.rgb_to_hsv(*p)[0] * 360 for p in rgb[fire]])
    return float((hues < 18).mean())


def amber_shift(rgba, below=18.0, lo=22.0, hi=30.0):
    """Move fire pixels (s > 0.5, v > 0.5) with hue under `below` degrees to hue lo..hi, keeping s and v."""
    out = rgba.copy()
    rgb = rgba[..., :3].astype(np.float32) / 255
    top, low = rgb.max(axis=2), rgb.min(axis=2)
    sat = (top - low) / np.maximum(top, 1e-6)
    fire = (sat > 0.5) & (top > 0.5) & (rgba[..., 3] > 0)
    for y, x in zip(*np.where(fire)):
        h, s, v = colorsys.rgb_to_hsv(*rgb[y, x])
        if h * 360 < below:
            h = (lo + (hi - lo) * h * 360 / below) / 360
            out[y, x, :3] = np.round(np.array(colorsys.hsv_to_rgb(h, s, v)) * 255)
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, default=HERE / "prologue_yard_sources/n28")
    parser.add_argument("--no-amber", action="store_true", help="skip the red-to-amber shift")
    args = parser.parse_args()
    for src, name in CUTS.items():
        sheet = Image.open(args.sources / f"{src}.png").convert("RGB")
        rgba = trimmed(despeckle(np.asarray(cut.key_full(sheet, WHITE, SHADOW))))
        before = red_share(rgba)
        if not args.no_amber:
            rgba = amber_shift(rgba)
        Image.fromarray(rgba).save(OUT / f"{name}.png")
        old = Image.open(OUT.parents[0] / SHIPPED[name]).size
        h, w = rgba.shape[:2]
        print(f"{name}: {w}x{h} aspect {w / h:.3f} vs shipped {old[0]}x{old[1]} {old[0] / old[1]:.3f}; red {before * 100:.2f}% -> {red_share(rgba) * 100:.2f}%")


if __name__ == "__main__":
    main()
