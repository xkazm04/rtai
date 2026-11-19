"""Measure right-profile stance on stride-film PNGs. Run with py -3 -I foot_slide.py TAKE.

The one-metre ground ticks below each figure move with the floor. The camera follows the
body. The stance landmark is the midpoint of the lowest 5% of the visible boot outline.
At contact the leading (right) sole takes weight; at run push-off the left sole leaves.
Walk contact lasts half a cycle. On run8 its fourth cell is flight and is excluded.
"""

import argparse
import hashlib
import json
from itertools import groupby
from pathlib import Path
from statistics import mean

import numpy as np
from PIL import Image


def spans(mask):
    """Half-open horizontal runs across a boolean scanline."""
    edges = np.flatnonzero(np.diff(np.r_[False, mask, False]))
    return list(zip(edges[::2], edges[1::2]))


def sole_x(mask, trailing=False):
    ys = np.flatnonzero(mask.any(axis=1))
    if not len(ys):
        raise ValueError("missing figure")
    depth = max(1, round((ys[-1] - ys[0]) * 0.05))
    runs = spans(mask[ys[-1] - depth:ys[-1] + 1].any(axis=0))
    # Suppress isolated antialiasing flecks but keep a narrow tilted boot.
    widest = max(b - a for a, b in runs)
    boots = [(a, b) for a, b in runs if b - a >= widest * 0.30]
    a, b = boots[0 if trailing else -1]
    return (a + b - 1) / 2


def landmarks(tile, ppm, trailing):
    """Read the sole and one complete world ruler tick from a native-resolution tile."""
    rgb = tile.astype(np.int16)
    floor = rgb[0, 0]
    figure = np.max(np.abs(rgb[:-12] - floor), axis=2) > 48
    marks = spans(np.min(rgb[-5], axis=1) > 200)
    full = [(a, b) for a, b in marks if a > 0 and b < tile.shape[1]]
    if len(full) < 2 or any(abs(c - a - ppm) > 1 for (a, _), (c, _) in zip(full, full[1:])):
        raise ValueError("missing or mis-scaled metre ruler")
    a, b = full[0]
    return sole_x(figure, trailing), (a + b - 1) / 2


def world_track(samples, ppm):
    """Unwrap the ruler and subtract camera travel from the boot in the same crop."""
    floor = samples[0][2]
    prev = floor
    result = []
    for col, boot, mark in samples:
        floor += (mark - prev + ppm / 2) % ppm - ppm / 2
        result.append((col, boot - floor, floor))
        prev = mark
    return result


def measure(samples, ppm, cols, running, first_tick=0):
    track = world_track(samples, ppm)
    half = cols // 2
    last = 2 if running else half - 1
    poses = []
    for col, group in groupby(enumerate(track, first_tick), key=lambda row: row[1][0]):
        ticks, points = zip(*group)
        poses.append((col, ticks, [p[1] for p in points]))
    # The first and last drawings may already be / still be held at the cut.
    poses = poses[1:-1]
    holds, steps = [], []
    for i, (col, ticks, xs) in enumerate(poses):
        if col % half <= last:
            holds.append(record(ticks, max(xs) - min(xs), ppm, col=col))
        if col % half:
            continue
        stance = poses[i:i + last + 1]
        if [p[0] for p in stance] != list(range(col, col + last + 1)):
            continue
        world = [x for _, _, points in stance for x in points]
        # Compare the centres of the held drawings: isolate net drift from the hold sawtooth.
        drift = mean(stance[-1][2]) - mean(stance[0][2])
        steps.append(record((ticks[0], stance[-1][1][-1]), abs(drift), ppm,
                            signed_cm=drift * 100 / ppm, range_cm=(max(world) - min(world)) * 100 / ppm))
    if not holds or not steps:
        raise ValueError("no complete stance in take")
    ground = (track[-1][2] - track[0][2]) / (len(track) - 1)
    return dict(ground_px_tick=ground, holds=holds, planted_steps=steps,
                hold=summary(holds), step=summary(steps), peak_excursion_cm=max(s["range_cm"] for s in steps))


def record(ticks, px, ppm, **extra):
    return dict(ticks=[ticks[0], ticks[-1]], px=px, cm=px * 100 / ppm, **extra)


def summary(rows):
    return {f"{stat}_{unit}": fn(row[unit] for row in rows)
            for stat, fn in (("mean", mean), ("max", max)) for unit in ("px", "cm")}


def analyze(take):
    info = json.loads((take / "film.json").read_text(encoding="utf-8"))
    first, ppm = info["first_tick"], info["ppm"]
    lanes = info["lanes"]
    times = {len(lane["columns"]) for lane in lanes}
    if len(times) != 1:
        raise ValueError("lanes have unequal footage")
    samples = [[] for _ in lanes]
    for i in range(times.pop()):
        with Image.open(take / f"t{first + i:03}.png") as frame:
            atlas = np.asarray(frame.convert("RGB"))
        for lane, points in zip(lanes, samples):
            x, y, w, h = lane["rect"]
            col = lane["columns"][i]
            trailing = lane["run"] and col % 4 == 2
            points.append((col, *landmarks(atlas[y:y+h, x:x+w], ppm, trailing)))
    rows = []
    for lane, points in zip(lanes, samples):
        row = measure(points, ppm, lane["cols"], lane["run"], first)
        rows.append({**{k: v for k, v in lane.items() if k not in ("columns", "rect")}, **row})
    return dict(schema="gtai.foot-slide/1", view=info["view"], ppm=ppm, lanes=rows)


def measure_strips(root):
    """Read profile row 2 from the two shipped pitches. Distances stay in packed texture px."""
    strips = {}
    for pitch in ("p55", "p70"):
        for name in ("rivet_walk8", "rivet_walk_eq_pistol", "rivet_run8", "rivet_run8_eq_pistol"):
            path = root / pitch / (name + ".png")
            cols = 4 if name == "rivet_walk_eq_pistol" else 8
            run = "run8" in name
            last = 2 if run else cols // 2 - 1
            with Image.open(path) as image:
                alpha = np.asarray(image.convert("RGBA"))[:, :, 3] >= 128
            h, w = alpha.shape[0] // 8, alpha.shape[1] // cols
            xs = [sole_x(alpha[2*h:3*h, c*w:(c+1)*w], run and c % 4 == 2) for c in range(cols)]
            travel = [xs[c] - xs[c + last] for c in (0, cols // 2)]
            strips[path.relative_to(root).as_posix()] = dict(
                sha256=hashlib.sha256(path.read_bytes()).hexdigest(), cols=cols, advances=last,
                sole_x=xs, travel_texels=travel, cycle_110_px=[d * cols / last / 1.5 for d in travel])
    return dict(schema="gtai.stride-lengths/1", profile_row=2, strips=strips)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("take", type=Path)
    parser.add_argument("--strips", action="store_true", help="measure packed strips under the given art root")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    result = measure_strips(args.take) if args.strips else analyze(args.take)
    if args.out:
        args.out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    else:
        print(json.dumps(result, indent=2))
