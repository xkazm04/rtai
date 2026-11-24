"""Rivet's body against the floor under him, from the --dusk captures (hero frame vs the frame with
the actor layer hidden). Pixels: |hero - ground| > 14 inside a 60 x 74 px box round his feet point
at 32 px/m, minus 24 px round any cop point. Delta = |mean luminance(body) - mean luminance(floor
under the same pixels)| on Rec.709 linear light, averaged over every exposure where he is on screen.

python rivet_delta.py <capture dir> [<capture dir> ...]
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image


def lum(rgb):
    s = rgb / 255.0
    lin = np.where(s <= 0.04045, s / 12.92, ((s + 0.055) / 1.055) ** 2.4)
    return lin @ [0.2126, 0.7152, 0.0722]


def deltas(root):
    out = []
    for frame in json.loads((root / "sample_points.json").read_text())["frames"]:
        label = frame["frame"]
        riv = [p for p in frame["points"] if p["kind"] == "rivet"]
        if not riv:
            continue
        hero = np.asarray(Image.open(root / f"{label}.png").convert("RGB"), dtype=float)
        ground = np.asarray(Image.open(root / f"{label}_ground.png").convert("RGB"), dtype=float)
        x, y = riv[0]["xy"]
        if not (40 < x < 1880 and 80 < y < 1040):
            continue
        yy, xx = np.mgrid[0:1080, 0:1920]
        box = (abs(xx - x) <= 30) & (yy >= y - 60) & (yy <= y + 14)
        for p in frame["points"]:
            if p["kind"] != "rivet":
                box &= (abs(xx - p["xy"][0]) > 24) | (abs(yy - p["xy"][1]) > 24)
        mask = box & (abs(hero - ground).max(axis=2) > 14)
        if mask.sum() < 150:
            continue
        out.append((frame["tick"], float(abs(lum(hero[mask]).mean() - lum(ground[mask]).mean())), int(mask.sum())))
    return out


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        rows = deltas(Path(arg))
        mean = float(np.mean([r[1] for r in rows])) if rows else float("nan")
        print(f"{arg}: rivet delta mean {mean:.4f} over {len(rows)} exposures " + " ".join(f"t{t}:{d:.3f}({n}px)" for t, d, n in rows))
