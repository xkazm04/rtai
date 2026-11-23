"""Recompute the 32 px/m contrast table from the lossless exposure strips beside this file.

To rebuild the PNGs, pass a directory containing the torn_line and line_fire outputs of
tools/art/prologue_yard_stills.mjs --dusk --dressing=<id> --out=<absolute directory>.
Each strip retains the original still pixels, the ground at those pixels, and the measured mask.
"""

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, PngImagePlugin


OUT = Path(__file__).resolve().parent
ARMS = ("torn_line", "line_fire")
KINDS = ("patrol_cop", "rifle", "shotgun")
W, H = 64, 80


def plate(captures, frame, ppm):
    pair = Image.new("RGB", (3840, 1112), "#231f20")
    pen = ImageDraw.Draw(pair)
    for i, arm in enumerate(ARMS):
        pair.paste(Image.open(captures / arm / f"{frame}.png"), (1920 * i, 32))
        title = "Daylight  /  torn_line" if i == 0 else "Dusk  /  line_fire"
        tick = frame[1:] if frame.startswith("t") else "2858"
        pen.text((1920 * i + 14, 8), f"{title}     Seed 7     Tick {tick}     {ppm} px/m",
                 fill="white", font_size=16)
    pair.save(OUT / f"dusk_{frame}_{ppm}ppm.png")


def examples(root, kind):
    """First qualifying exposure, all on-screen examples; overlapping pellet pixels count once."""
    frames = json.loads((root / "sample_points.json").read_text())["frames"]
    for frame in frames:
        points = [p for p in frame["points"] if p["kind"] == kind]
        if not points:
            continue
        label = frame["frame"]
        hero = Image.open(root / f"{label}.png").convert("RGB")
        ground = Image.open(root / f"{label}_ground.png").convert("RGB")
        under = ground if kind == "patrol_cop" else Image.open(root / f"{label}_no_rounds.png")
        counted = np.zeros((hero.height, hero.width), dtype=bool)
        found = False
        for point in points:
            x, y = point["xy"]
            left, top = x - W // 2, y - 64
            box = (left, top, left + W, top + H)
            if left < 0 or top < 0 or box[2] > hero.width or box[3] > hero.height:
                continue
            fg, bg, off = [np.asarray(img.crop(box).convert("RGB"), dtype=int)
                           for img in (hero, ground, under)]
            r, g, b = fg.transpose(2, 0, 1)
            yy, xx = np.mgrid[-64:H-64, -W//2:W//2]
            if kind == "patrol_cop":
                mask = (abs(xx) < 16) & (yy >= -55) & (yy < -15) & (b > r + 13) & (b > g + 6)
            else:
                mask = (abs(xx) <= 6) & (abs(yy) <= 6) & (r > g + 8) & (g > b + 16)
                # Reject intersections with rigs or nameplates under a live round.
                mask &= abs(off - bg).max(axis=2) <= 2
            taken = counted[top:box[3], left:box[2]]
            mask &= (abs(fg - off).max(axis=2) > 6) & ~taken
            if mask.any():
                found = True
                taken |= mask
                yield (root.name, kind, frame["tick"], x, y), hero.crop(box), ground.crop(box), mask
        if found:
            return
    raise ValueError(f"no measurable {kind} in {root}")


def make_strips(captures):
    rows = [item for arm in ARMS for kind in KINDS for item in examples(captures / arm, kind)]
    atlas = Image.new("RGB", (500, len(rows) * H), "#231f20")
    pen = ImageDraw.Draw(atlas)
    for i, (data, fg, bg, mask) in enumerate(rows):
        y = i * H
        atlas.paste(fg, (0, y))
        atlas.paste(bg, (W, y))
        atlas.paste(Image.fromarray(mask), (2 * W, y))
        arm, kind, tick, x, sy = data
        pen.text((208, y + 16), f"{arm}   /   {kind}", fill="white", font_size=16)
        pen.text((208, y + 42), f"Tick {tick}   |   Screen ({x}, {sy})", fill="white", font_size=13)
    meta = PngImagePlugin.PngInfo()
    meta.add_text("samples", json.dumps([r[0] for r in rows]))
    atlas.save(OUT / "dusk_samples.png", pnginfo=meta)


def luminance(rgb):
    srgb = rgb / 255.0
    linear = np.where(srgb <= 0.04045, srgb / 12.92, ((srgb + 0.055) / 1.055) ** 2.4)
    return linear @ [0.2126, 0.7152, 0.0722]


def measure():
    atlas = Image.open(OUT / "dusk_samples.png")
    rgb = np.asarray(atlas)
    samples = {}
    for i, (arm, kind, *_) in enumerate(json.loads(atlas.info["samples"])):
        row = rgb[i * H:(i + 1) * H]
        mask = row[:, W * 2:W * 3, 0] > 0
        fg, bg = [luminance(row[:, j:j+W][mask]) for j in (0, W)]
        ratio = (np.maximum(fg, bg) + 0.05) / (np.minimum(fg, bg) + 0.05)
        samples.setdefault((arm, kind), []).extend(ratio)
    ok = True
    for kind in KINDS:
        a, b = [samples[(arm, kind)] for arm in ARMS]
        retained = np.mean(b) / np.mean(a)
        print(f"{kind:12}  {np.mean(a):.3f}  {np.mean(b):.3f}  {retained:.1%}  ({len(a)}, {len(b)} px)")
        ok &= retained >= 2/3
    return ok


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--captures", type=Path)
    args = parser.parse_args()
    if args.captures:
        for frame in ("t2858", "t6000", "gate", "front"):
            plate(args.captures, frame, 32 if frame.startswith("t") else 64)
        make_strips(args.captures)
    raise SystemExit(0 if measure() else 1)
