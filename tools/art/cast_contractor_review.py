"""Numbers from cast_contractor_poses.mjs: live rim at 64 px/m, ring-off shadow counts at 32, live palette.
usage: python tools/art/cast_contractor_review.py <folder holding poses70_32, poses70_64, poses55_64>"""
import argparse
import colorsys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_mulroney_edge import rim

RIMS = ("planted8_armed_walk", "attack", "hit", "hit_calm", "fall", "fall_1", "fall_2")


def load(path):
    return np.asarray(Image.open(path).convert("RGB"), dtype=int)


def rims(folder):
    for pitch in (70, 55):
        for name in RIMS:
            d = folder / f"poses{pitch}_64" / ("edge_" + name)
            if not d.exists():
                continue
            visible = int((abs(load(d / "raw.png") - load(d / "ground.png")).max(2) > 22).sum())
            print(pitch, name, "added dark exterior pixels", rim(d), "visible pixels", visible)


def shadows(folder):
    for pitch in (70,):
        d = folder / f"poses{pitch}_32"
        for on in sorted(d.glob("*.png")):
            off = on.with_name(on.stem + "_no_shadow.png")
            if on.stem.endswith("_no_shadow") or not off.exists():
                continue
            a, b = load(on), load(off)
            print(pitch, 32, on.stem, "pixels darkened >= 12:", int(((b - a).max(2) >= 12).sum()))


def hsv(rgb):
    return np.array([colorsys.rgb_to_hsv(*(p / 255)) for p in rgb.reshape(-1, 3)]).reshape(rgb.shape)


def palette(folder):
    """Hat and vest on the live frame (the figure = live differs from the empty ground), plus stray hues."""
    for pitch in (70, 55):
        for name in ("planted8_armed_walk", "attack"):
            d = folder / f"poses{pitch}_64" / ("edge_" + name)
            live, ground = load(d / "live.png"), load(d / "ground.png")
            ys, xs = np.nonzero(abs(live - ground).max(2) > 22)
            top, bottom = ys.min(), ys.max()
            solid = (abs(live - ground).max(2) > 22) & (live.max(2) >= 60)
            band = np.zeros_like(solid)
            band[top:top + max(1, round((bottom - top) * 0.2))] = True
            h = hsv(live.astype(float))
            # Hat: the pale pixels of the top fifth (the lamp and skin are warmer or darker).
            hat = solid & band & (h[..., 1] < 0.35) & (h[..., 2] > 0.6)
            vest = solid & ~band & (h[..., 0] * 360 > 30) & (h[..., 0] * 360 < 90) & (h[..., 1] > 0.3) & (h[..., 2] > 0.5)
            hue = h[..., 0] * 360
            r, g, b = (live[..., i] for i in range(3))
            stray = {
                "red": (r > 150) & (g < 60) & (b < 60),
                "vermilion": (hue >= 5) & (hue <= 22) & (h[..., 1] > 0.7) & (h[..., 2] > 0.7),
                "teal": (hue >= 160) & (hue <= 200) & (h[..., 1] > 0.35) & (h[..., 2] > 0.3),
                "blue/navy": (hue >= 200) & (hue <= 260) & (h[..., 1] > 0.3) & (h[..., 2] > 0.15),
            }
            out = {k: int((v & solid).sum()) for k, v in stray.items()}
            print(pitch, name, "hat px", int(hat.sum()), "S %.3f V %.3f" % (h[hat][:, 1].mean(), h[hat][:, 2].mean()),
                  "| vest px", int(vest.sum()), "median hue %.1f" % np.median(hue[vest]),
                  "share < 45: %.1f %%" % (100 * (hue[vest] < 45).mean()), "| stray", out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    args = parser.parse_args()
    rims(args.folder)
    shadows(args.folder)
    palette(args.folder)
